//
//  OpenMarketTests.swift
//  OpenMarketTests
//
//  Created by marisol on 2022/05/11.
//

import XCTest
@testable import OpenMarket

class OpenMarketTests: XCTestCase {
    var sut: NetworkManager<Products>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = NetworkManager<Products>(session: URLSession.shared)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
    }
    
    func test_response를success로정해두고_dummy데이터와_실제값의일치여부확인() {
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
        
        sut.session = stubUrlSession
        
        var totalCount: Int = 0
        
        sut.execute(with: url) { result in
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
}
