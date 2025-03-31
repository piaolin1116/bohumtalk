//
//  NetworkRequestManager.swift
//  BohumTalk
//
//  Created by 조유진 on 3/28/25.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid HTTP response"
        case .invalidData:
            return "Invalid data"
        }
    }
}

final class NetworkRequestManager {
    static let shared = NetworkRequestManager()
    private var BASE_URL: String {
        guard let aesKey = Bundle.main.infoDictionary?["BASE_URL"] as? String else {
            fatalError("BASE_URL not found in Info.plist")
        }
        return aesKey
    }
    
    private init() {}
    
    func requestPostToServer(url: String, parameters: [String : Any]) async throws -> String {
        let requestBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])

        let urlString = BASE_URL + url
        guard let url = URL(string: urlString) else {
          print("Error: cannot create URL")
          throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody
          
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
          
        guard let responseData = try? JSONDecoder().decode(String.self, from: data) else {
            throw NetworkError.invalidData
        }
        return responseData
    }
}
