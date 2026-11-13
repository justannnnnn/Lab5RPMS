//
//  CharacterListViewModel.swift
//  Lab5_RPMS_Kiritseva
//
//  Created by Ann Kiritseva on 13.11.2026.
//

import Foundation
import Combine

@MainActor
final class CharacterListViewModel: ObservableObject {

    @Published private(set) var characters: [DisneyCharacter] = []

    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false

    @Published var searchText = ""

    @Published private(set) var errorMessage: String?

    private let service = DisneyAPIService.shared

    private var nextPageURL: URL?

    // MARK: - Initial Loading

    func loadCharacters() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let response = try await service.fetchCharacters(
                name: searchText.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            )

            try Task.checkCancellation()

            characters = response.data
            nextPageURL = response.info?.nextPage.flatMap {
                URL(string: $0)
            }

        } catch is CancellationError {
            return
        } catch let error as URLError where error.code == .cancelled {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Search

    func searchCharacters() async {
        await loadCharacters()
    }

    // MARK: - Pagination

    func loadNextPage() async {
        guard let nextPageURL,
              !isLoading,
              !isLoadingMore else {
            return
        }

        isLoadingMore = true

        defer {
            isLoadingMore = false
        }

        do {
            let response = try await service.fetchCharacters(
                from: nextPageURL
            )

            try Task.checkCancellation()

            let existingIDs = Set(
                characters.map(\.id)
            )

            let newCharacters = response.data.filter {
                !existingIDs.contains($0.id)
            }

            characters.append(contentsOf: newCharacters)

            self.nextPageURL = response.info?.nextPage.flatMap {
                URL(string: $0)
            }

        } catch is CancellationError {
            return
        } catch let error as URLError where error.code == .cancelled {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Retry

    func retry() async {
        if characters.isEmpty {
            await loadCharacters()
        } else {
            await loadNextPage()
        }
    }
}
