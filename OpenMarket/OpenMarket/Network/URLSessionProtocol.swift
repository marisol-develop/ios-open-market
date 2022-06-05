//
//  URLSessionProtocol.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/05/10.
//

import Foundation

typealias DataTaskCompletionHandler = (Response) -> Void

struct Response {
    var data: Data?
    var statusCode: Int
    var error: Error?
}

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskCompletionHandler)
    func dataTask(with url: URL, completionHandler: @escaping DataTaskCompletionHandler)
}

extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskCompletionHandler) {
        
        dataTask(with: request) { data, response, error in
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            
            let response = Response(data: data, statusCode: statusCode, error: error)
            completionHandler(response)
        }.resume()
    }
    
    func dataTask(with url: URL, completionHandler: @escaping DataTaskCompletionHandler) {
        dataTask(with: url) { data, response, error in
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            
            let response = Response(data: data, statusCode: statusCode, error: error)
            completionHandler(response)
        }.resume()
    }
}
