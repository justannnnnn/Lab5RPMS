//
//  DisneyCharacter.swift
//  Lab5_RPMS_Kiritseva
//
//  Created by Ann Kiritseva on 13.11.2026.
//

import Foundation

struct DisneyCharacter: Codable, Identifiable {
    let id: Int
    let name: String

    let imageUrl: String?
    let sourceUrl: String?
    let url: String?

    let films: [String]?
    let shortFilms: [String]?
    let tvShows: [String]?
    let videoGames: [String]?
    let parkAttractions: [String]?

    let allies: [String]?
    let enemies: [String]?

    let alignment: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case imageUrl
        case sourceUrl
        case url
        case films
        case shortFilms
        case tvShows
        case videoGames
        case parkAttractions
        case allies
        case enemies
        case alignment
    }
}

// MARK: - Pagination Information

struct CharacterPageInfo: Codable {
    let count: Int?
    let totalPages: Int?
    let previousPage: String?
    let nextPage: String?
}

// MARK: - Characters List Response

struct CharactersResponse: Codable {
    let info: CharacterPageInfo?
    let data: [DisneyCharacter]
}

// MARK: - Single Character Response

struct CharacterDetailResponse: Codable {
    let info: CharacterPageInfo?
    let data: DisneyCharacter
}
