//
//  CharacterDetailView.swift
//  Lab5_RPMS_Kiritseva
//
//  Created by Ann Kiritseva on 13.11.2026.
//

import SwiftUI

struct CharacterDetailView: View {

    let characterID: Int

    @EnvironmentObject private var networkMonitor: NetworkMonitor

    @State private var character: DisneyCharacter?
    @State private var isLoading = true
    @State private var errorMessage: String?

    private let service = DisneyAPIService.shared

    var body: some View {
        ScrollView {

            VStack(alignment: .leading, spacing: 20) {

                if !networkMonitor.isConnected {
                    networkUnavailableBanner
                }

                if isLoading {

                    ProgressView("Загрузка информации...")
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)

                } else if let errorMessage {

                    errorView(errorMessage)

                } else if let character {

                    characterContent(character)
                }
            }
            .padding()
        }
        .navigationTitle(character?.name ?? "Персонаж")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadCharacter()
        }
    }

    // MARK: - Character Content

    @ViewBuilder
    private func characterContent(
        _ character: DisneyCharacter
    ) -> some View {

        VStack(alignment: .leading, spacing: 18) {

            // Image

            AsyncImage(
                url: character.imageUrl.flatMap(URL.init(string:))
            ) { phase in

                switch phase {

                case .empty:
                    imagePlaceholder

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 16)
                        )

                case .failure:
                    imagePlaceholder

                @unknown default:
                    imagePlaceholder
                }
            }
            .frame(maxHeight: 300)

            // Name

            Text(character.name)
                .font(.largeTitle)
                .fontWeight(.bold)

            // ID

            Text("Character ID: \(character.id)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Alignment

            if let alignment = character.alignment {
                detailSection(
                    title: "Alignment",
                    items: [alignment]
                )
            }

            // Films

            detailSection(
                title: "Films",
                items: character.films
            )

            // Short Films

            detailSection(
                title: "Short Films",
                items: character.shortFilms
            )

            // TV Shows

            detailSection(
                title: "TV Shows",
                items: character.tvShows
            )

            // Video Games

            detailSection(
                title: "Video Games",
                items: character.videoGames
            )

            // Park Attractions

            detailSection(
                title: "Park Attractions",
                items: character.parkAttractions
            )

            // Allies

            detailSection(
                title: "Allies",
                items: character.allies
            )

            // Enemies

            detailSection(
                title: "Enemies",
                items: character.enemies
            )

            // Source

            if let sourceUrl = character.sourceUrl,
               let url = URL(string: sourceUrl) {

                Link(
                    "Open character source",
                    destination: url
                )
                .font(.headline)
            }
        }
    }

    // MARK: - Detail Section

    @ViewBuilder
    private func detailSection(
        title: String,
        items: [String]?
    ) -> some View {
        
        if let items, !items.isEmpty {

            VStack(alignment: .leading, spacing: 8) {

                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)

                ForEach(
                    Array(items.enumerated()),
                    id: \.offset
                ) { _, item in

                    HStack(alignment: .top, spacing: 8) {

                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .padding(.top, 6)

                        Text(item)
                            .font(.body)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                Color(uiColor: .secondarySystemBackground)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
        }
    }

    // MARK: - Image Placeholder

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.gray.opacity(0.15))
            .frame(height: 220)
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
            }
    }

    // MARK: - Network Banner

    private var networkUnavailableBanner: some View {
        Label(
            "Нет подключения к интернету",
            systemImage: "wifi.slash"
        )
        .font(.subheadline)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.red)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {

            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)

            Text("Не удалось загрузить персонажа")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Повторить") {
                Task {
                    await loadCharacter()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
    }

    // MARK: - Load Character

    @MainActor
    private func loadCharacter() async {

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            character = try await service.fetchCharacter(
                id: characterID
            )

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
