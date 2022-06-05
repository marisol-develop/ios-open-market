//
//  APIable.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/05/29.
//

import Foundation

struct Item: Encodable {
    let name: String?
    let descriptions: String?
    let price: Int?
    let thumbnailID: Int?
    let currency: Currency?
    let discountedPrice: Int?
    let stock: Int?
    let secret: String?
    var images: [ImageInfo]?
    
    private enum CodingKeys: String, CodingKey {
        case name, descriptions, price, currency, stock, secret, images
        case thumbnailID = "thumbnail_id"
        case discountedPrice = "discounted_price"
    }
}

protocol APIable {
    var url: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var item: Item? { get }
    var params: [String: String]? { get }
    var productId: Int? { get }
    var secret: String? { get }
}

struct List: APIable {
    let url: String = "https://market-training.yagom-academy.kr/"
    let path: String = "api/products"
    let method: HTTPMethod = .get
    let item: Item? = nil
    let pageNo: Int
    let itemsPerPage: Int
    var params: [String: String]? {
        return ["page_no": String(pageNo),
                "items_per_page": String(itemsPerPage)]
    }
    var productId: Int? = nil
    var secret: String? = nil
}

struct Detail: APIable {
    let url: String = "https://market-training.yagom-academy.kr/"
    let path: String = "api/products"
    let method: HTTPMethod = .get
    let item: Item? = nil
    var params: [String: String]? = nil
    var productId: Int?
    var secret: String? = nil
}

struct Registration: APIable {
    var url: String = "https://market-training.yagom-academy.kr/"
    var path: String = "api/products"
    var method: HTTPMethod = .post
    var item: Item?
    var params: [String : String]? = nil
    var productId: Int? = nil
    var secret: String? = nil
}

struct Edit: APIable {
    var url: String = "https://market-training.yagom-academy.kr/"
    var path: String = "api/products"
    var method: HTTPMethod = .patch
    var item: Item?
    var params: [String : String]? = nil
    var productId: Int?
    var secret: String? = nil
}

struct Delete: APIable {
    var url: String = "https://market-training.yagom-academy.kr/"
    var path: String = "api/products"
    var method: HTTPMethod = .delete
    var item: Item? = nil
    var params: [String : String]? = nil
    var productId: Int?
    var secret: String?
}

struct Secret: APIable {
    var url: String = "https://market-training.yagom-academy.kr/"
    var path: String = "api/products"
    var method: HTTPMethod = .post
    var item: Item? = nil
    var params: [String : String]? = nil
    var productId: Int?
    var secret: String? = nil
}
