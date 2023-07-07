//
//  RequestProcessor.swift
//  ToDo
//
//  Created by Elizaveta Osipova on 7/7/23.
//

import Foundation

struct Constants {
    static let scheme = "https"
    static let host = "beta.mrdekk.ru"
    static let path = "/todobackend/list"
    static let token = "Bearer torrider"
}

enum RequestProcessor {
    static func makeURL(from id: String? = nil) throws -> URL {
        var components = URLComponents()
        components.scheme = Constants.scheme
        components.host = Constants.host
        components.path = id.map { Constants.path + "/\($0)" } ?? Constants.path
        guard let url = components.url else {
            throw RequestProcessorErrors.wrongURL(components)
        }
        return url
    }
    
    static func performRequest(with url: URL, method: httpMethods = .get, revision: Int? = nil, httpBody: Data? = nil) async throws -> (Data, HTTPURLResponse) {
        let request = try makeURLRequest(url: url, method: method, revision: revision, httpBody: httpBody)
        return try await performDataTask(for: request)
    }
    
    private static func makeURLRequest(url: URL, method: httpMethods, revision: Int?, httpBody: Data?) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue(Constants.token, forHTTPHeaderField: "Authorization")
        if let revision {
            request.addValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        }
        request.httpMethod = method.rawValue
        request.httpBody = httpBody
        return request
    }
    
    private static func performDataTask(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let session = URLSession(configuration: .default)
//        let (data, response) = try await session.dataTaskCustom(for: request)
        let (data, response) = try await session.data(for: request)
        guard let httpURLResponse = response.httpURLResponse,
              httpURLResponse.isSuccessful else {
            throw RequestProcessorErrors.requestFailed(response)
        }
        return (data, httpURLResponse)
    }
    
    enum httpMethods: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }
}

enum RequestProcessorErrors: Error {
    case wrongURL(URLComponents)
    case requestFailed(URLResponse)
}

extension URLResponse {
    var httpURLResponse: HTTPURLResponse? {
        self as? HTTPURLResponse
    }
}

extension HTTPURLResponse {
    var isSuccessful: Bool {
        200 ... 299 ~= statusCode
    }
}


