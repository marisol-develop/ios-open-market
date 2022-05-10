//
//  MockURLSession.swift
//  OpenMarket
//
//  Created by marisol on 2022/05/10.
//

import Foundation

struct MockData {
    let data = Data()
}

final class MockURLSessionDataTask: URLSessionDataTask {
    var completion: () -> Void = {}
    
    override func resume() {
        completion()
    }
}
