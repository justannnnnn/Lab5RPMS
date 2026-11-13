//
//  CharacterRowView.swift
//  Lab5_RPMS_Kiritseva
//
//  Created by Ann Kiritseva on 13.11.2026.
//

import SwiftUI

struct CharacterRowView: View {

    let character: DisneyCharacter

    var body: some View {
        HStack(spacing: 14) {

            AsyncImage(url: imageURL) { phase in

                switch phase {

                case .empty:
                    placeholder

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 85, height: 85)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 12)
                        )

                case .failure:
                    placeholder

                @unknown default:
                    placeholder
                }
            }

            VStack(alignment: .leading, spacing: 6) {

                Text(character.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if let films = character.films,
                   !films.isEmpty {

                    Text(films.prefix(2).joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)

                } else {
                    Text("Информация о фильмах отсутствует")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("ID: \(character.id)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 5)
    }

    private var imageURL: URL? {
        guard let imageUrl = character.imageUrl else {
            return nil
        }

        return URL(string: imageUrl)
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.15))
            .frame(width: 85, height: 85)
            .overlay {
                Image(systemName: "person.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
    }
}
