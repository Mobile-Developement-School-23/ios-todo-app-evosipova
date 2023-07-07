//
//  URLSession.swift
//  ToDo
//
//  Created by Elizaveta Osipova on 7/7/23.
//

import Foundation

extension URLSession {
    func dataTaskCustom(for request: URLRequest) async throws -> (Data, URLResponse) {
        var dataTask: URLSessionDataTask?
        let cancelDataTask = { dataTask?.cancel() }
        
        return try await withTaskCancellationHandler(operation: {
            try Task.checkCancellation()
            return try await withCheckedThrowingContinuation { continuation in
                dataTask = self.dataTask(with: request) { data, response, error in
                    guard let data = data, let response = response else {
                        let error = error ?? URLError(.badServerResponse)
                        return continuation.resume(throwing: error)
                    }
                    continuation.resume(returning: (data, response))
                }
                dataTask?.resume()
            }
        }, onCancel: {
            cancelDataTask()
        })
    }
}
