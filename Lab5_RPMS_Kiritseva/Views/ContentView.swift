//
//  ContentView.swift
//  Lab5_RPMS_Kiritseva
//
//  Created by Ann Kiritseva on 13.11.2026.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = CharacterListViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()

    var body: some View {
        NavigationStack {

            VStack(spacing: 0) {

                // Network Status

                if !networkMonitor.isConnected {
                    networkUnavailableBanner
                }

                // Error Message

                if let error = viewModel.errorMessage {
                    errorBanner(error)
                }

                // Characters List

                if viewModel.isLoading && viewModel.characters.isEmpty {

                    Spacer()

                    ProgressView("Загрузка персонажей...")

                    Spacer()

                } else if viewModel.characters.isEmpty {

                    emptyState

                } else {

                    charactersList
                }
            }
            .navigationTitle("Disney Characters")
            .searchable(
                text: $viewModel.searchText,
                prompt: "Поиск персонажа"
            )
            .onSubmit(of: .search) {
                Task {
                    await viewModel.searchCharacters()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.searchCharacters()
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .task {
                await viewModel.loadCharacters()
            }
            .refreshable {
                await viewModel.searchCharacters()
            }
        }
        .environmentObject(networkMonitor)
    }

    // MARK: - Characters List

    private var charactersList: some View {
        List {

            ForEach(viewModel.characters) { character in

                NavigationLink {
                    CharacterDetailView(characterID: character.id)
                } label: {
                    CharacterRowView(character: character)
                }
                .onAppear {
                    if character.id == viewModel.characters.last?.id {
                        Task {
                            await viewModel.loadNextPage()
                        }
                    }
                }
            }

            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView("Загрузка...")
                    Spacer()
                }
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Network Banner

    private var networkUnavailableBanner: some View {
        HStack(spacing: 10) {

            Image(systemName: "wifi.slash")

            Text("Нет подключения к интернету")
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer()
        }
        .foregroundStyle(.white)
        .padding()
        .background(Color.red)
    }

    // MARK: - Error Banner

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 10) {

            Image(systemName: "exclamationmark.triangle")

            Text(message)
                .font(.caption)
                .lineLimit(3)

            Spacer()

            Button("Повторить") {
                Task {
                    await viewModel.retry()
                }
            }
            .font(.caption)
            .fontWeight(.semibold)
        }
        .padding()
        .background(Color.orange.opacity(0.15))
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {

            Image(systemName: "person.2.slash")
                .font(.system(size: 42))
                .foregroundStyle(.secondary)

            Text("Персонажи не найдены")
                .font(.headline)
            Text("Попробуйте изменить поисковый запрос.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Button("Повторить загрузку") {
                            Task {
                                await viewModel.searchCharacters()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                }
            }
