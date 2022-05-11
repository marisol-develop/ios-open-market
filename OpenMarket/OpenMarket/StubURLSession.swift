//
//  StubURLSession.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/05/10.
//

import Foundation
import UIKit

struct DummyData {
    let data: Data?
    let response: HTTPURLResponse?
    let error: Error?
    var completionHandler: DataTaskCompletionHandler?
    
    func completion() {
        completionHandler?(data, response, error)
    }
}

final class StubURLSessionDataTask: URLSessionDataTask {
    var completion: () -> Void = {}
    
    override func resume() {
        completion()
    }
}

final class StubURLSession: URLSessionProtocol {
    private var isRequestSuccess: Bool
    private var sessionDataTask: StubURLSessionDataTask?
    
    init(isRequestSucceses: Bool = true) {
        self.isRequestSuccess = isRequestSucceses
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let sessionDataTask = StubURLSessionDataTask()
        
        guard let url = request.url else {
            return URLSessionDataTask()
        }
        
        let successResponse = HTTPURLResponse(url: url,
                                              statusCode: 200,
                                              httpVersion: "2",
                                              headerFields: nil)
        let failureResponse = HTTPURLResponse(url: url,
                                              statusCode: 404,
                                              httpVersion: "2",
                                              headerFields: nil)
        
        if isRequestSuccess {
            sessionDataTask.completion = {
                completionHandler(DummyData().data, successResponse, nil)
            }
        } else {
            sessionDataTask.completion = {
                completionHandler(nil, failureResponse, nil)
            }
        }

        return sessionDataTask
    }
}
