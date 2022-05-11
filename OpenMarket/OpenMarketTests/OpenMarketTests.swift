//
//  OpenMarketTests.swift
//  OpenMarketTests
//
//  Created by Eddy, marisol on 2022/05/11.
//

import XCTest
@testable import OpenMarket

class OpenMarketTests: XCTestCase {
    var sutProduct: NetworkManager<Products>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sutProduct = NetworkManager<Products>(session: URLSession.shared)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sutProduct = nil
    }
    
    func test_response를_success로정해두고_product의_dummy데이터와_실제값이일치한다() {
        let promise = expectation(description: "success")
        guard let url = URL(string: "fakeURL") else {
            return
        }
        
        guard let dummyData = NSDataAsset(name: "products") else {
            return
        }
        
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let dummy = DummyData(data: dummyData.data, response: response, error: nil)
        let stubUrlSession = StubURLSession(dummy: dummy)
        
        sutProduct.session = stubUrlSession
        
        var totalCount: Int = 0
        
        sutProduct.execute(with: url) { result in
            switch result {
            case .success(let product):
                totalCount = product.totalCount
            case .failure(let error):
                print(error.localizedDescription)
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10)
        XCTAssertEqual(totalCount, 10)
    }
    
    func test_response를_fail로정해두고_product의_statusCodeError타입확인한다() {
        let promise = expectation(description: "failure")
        guard let url = URL(string: "fakeURL") else {
            return
        }
        
        guard let dummyData = NSDataAsset(name: "products") else {
            return
        }
        
        let response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
        let dummy = DummyData(data: dummyData.data, response: response, error: nil)
        let stubUrlSession = StubURLSession(dummy: dummy)
        
        sutProduct.session = stubUrlSession
        
        var totalCount: Int = 0
        var errorResult: NetworkError? = nil
        
        sutProduct.execute(with: url) { result in
            switch result {
            case .success(let product):
                totalCount = product.totalCount
            case .failure(let error):
                errorResult = error
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10)
        XCTAssertNotEqual(totalCount, 10)
        XCTAssertEqual(errorResult, NetworkError.statusCode)
    }
    
    func test_response를_success로정해두고_productDetail의_dummy데이터와_실제값이일치한다() {
        let promise = expectation(description: "success")
        guard let url = URL(string: "fakeURL") else {
            return
        }
        
        guard let dummyData = NSDataAsset(name: "products") else {
            return
        }
        
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let dummy = DummyData(data: dummyData.data, response: response, error: nil)
        let stubUrlSession = StubURLSession(dummy: dummy)
        
        sutProduct.session = stubUrlSession
        
        var venderId: Int = 0
        
        sutProduct.execute(with: url) { result in
            switch result {
            case .success(let product):
                
                venderId = product.pages[0].vendorId
            case .failure(let error):
                print(error.localizedDescription)
            }
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 10)
        XCTAssertEqual(venderId, 3)
    }
    
        let response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
        let dummy = DummyData(data: dummyData.data, response: response, error: nil)
        let stubUrlSession = StubURLSession(dummy: dummy)
    }
}
