//
//  DisneyAPIService.swift
//  Lab5_RPMS_Kiritseva
//
//  Created by Ann Kiritseva on 13.11.2026.
//

import Foundation

enum DisneyAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный адрес запроса."

        case .invalidResponse:
            return "Сервер вернул некорректный ответ."

        case .serverError(let code):
            return "Ошибка сервера. Код: \(code)."
        }
    }
}

final class DisneyAPIService {

    static let shared = DisneyAPIService()

    private let baseURL = "https://api.disneyapi.dev"

    private init() {}

    // MARK: - Get Characters

    func fetchCharacters(
        name: String? = nil
    ) async throws -> CharactersResponse {

        guard var components = URLComponents(
            string: "\(baseURL)/character"
        ) else {
            throw DisneyAPIError.invalidURL
        }

        var queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "pageSize", value: "50")
        ]

        if let name, !name.isEmpty {
            queryItems.append(
                URLQueryItem(name: "name", value: name)
            )
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw DisneyAPIError.invalidURL
        }

        return try await fetchCharacters(from: url)
    }

    // MARK: - Get Next Page

    func fetchCharacters(
        from url: URL
    ) async throws -> CharactersResponse {

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DisneyAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw DisneyAPIError.serverError(
                httpResponse.statusCode
            )
        }

        return try JSONDecoder().decode(
            CharactersResponse.self,
            from: data
        )
    }

    // MARK: - Get One Character

    func fetchCharacter(
        id: Int
    ) async throws -> DisneyCharacter {

        guard let url = URL(
            string: "\(baseURL)/character/\(id)"
        ) else {
            throw DisneyAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DisneyAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw DisneyAPIError.serverError(
                httpResponse.statusCode
            )
        }

        let result = try JSONDecoder().decode(
            CharacterDetailResponse.self,
            from: data
        )

        return result.data
    }
}
