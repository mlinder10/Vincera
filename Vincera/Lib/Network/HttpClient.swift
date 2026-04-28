//
//  HttpClient.swift
//  Vincera
//
//  Created by Matt Linder on 12/1/25.
//

import Foundation

private let ENABLE_LOGGING = false
private let DISABLE_NETWORK = false

struct NetworkError: Error {
    let message: String
}

enum RequestMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case patch = "PATCH"
  case delete = "DELETE"
}

final class HttpClient {
    private var baseUrl: String
    private var headers: [String: String]
    private let encoder = JSONEncoder()
    
    init(baseUrl: String = "", headers: [String: String] = [:]) {
        self.baseUrl = baseUrl
        self.headers = headers
        encoder.dateEncodingStrategy = .iso8601
    }
    
    func request(
        _ route: String,
        method: RequestMethod = .get,
        headers: [String: String] = [:],
        body: [String: Any] = [:]
    ) async throws -> (Data, URLResponse) {
        let encodedBody = try JSONSerialization.data(withJSONObject: body)
        return try await self.request(route, method: method, headers: headers, body: encodedBody)
    }
    
    func request(
        _ route: String,
        method: RequestMethod = .get,
        headers: [String: String] = [:],
        body: any Encodable
    ) async throws -> (Data, URLResponse) {
        let encodedBody = try encoder.encode(body)
        return try await self.request(route, method: method, headers: headers, body: encodedBody)
    }
    
    func request(
        _ route: String,
        method: RequestMethod = .get,
        headers: [String: String] = [:],
        body: Data
    ) async throws -> (Data, URLResponse) {
        if DISABLE_NETWORK { throw NetworkError(message: "Network Disabled") }
        guard let url = URL(string: "\(baseUrl)\(route)") else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = self.headers.merging(headers) { $1 }
        
        if method == .post || method == .put || method == .patch {
            request.httpBody = body
        }
        
        let (data, res) = try await URLSession.shared.data(for: request)
        
        if ENABLE_LOGGING {
            print(String(data: data, encoding: .utf8) ?? "Failed to decode response")
        }
        
        return (data, res)
    }
    
    func config(baseUrl: String? = nil, headers: [String: String] = [:]) {
        self.baseUrl = baseUrl ?? self.baseUrl
        self.headers.merge(headers) { $1 }
    }
    
    func config(mutateHeaders: @escaping ([String: String]) -> [String: String]) {
        self.headers = mutateHeaders(self.headers)
    }
}
