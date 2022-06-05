//
//  NetworkManager.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/05/10.
//

import Foundation

private enum UserInformation {
    static let identifier: String = "affb87d9-d1b7-11ec-9676-d3cd1a738d6f"
    static let secret: String = "c7ne65d5oc"
}

enum NetworkError: Error {
    case error
    case data
    case statusCode
    case decode
    case request
}

struct ImageInfo: Encodable {
    let fileName: String
    let data: Data
    let type: String
}

struct NetworkManager {
    private var session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    mutating func execute(with apiAble: APIable, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        let successRange = 200...299
        var request: URLRequest?
        
        switch apiAble.method {
        case .get:
            var urlComponent = URLComponents(string: apiAble.url + apiAble.path)
            
            if apiAble.params != nil {
                urlComponent?.queryItems = apiAble.params?.compactMap{
                    URLQueryItem(name: $0.key, value: $0.value)
                }
            } else {
                guard let intId = apiAble.productId else {
                    return
                }
                
                let productId = "/\(String(intId))"
                
                urlComponent = URLComponents(string: apiAble.url + apiAble.path + productId)
            }
            
            guard let url = urlComponent?.url else {
                return
            }
            
            session.dataTask(with: url) { response in
                guard response.error == nil else {
                    completion(.failure(.error))
                    return
                }
                
                guard successRange.contains(response.statusCode) else {
                    completion(.failure(.statusCode))
                    return
                }
                
                guard let data = response.data else {
                    completion(.failure(.data))
                    return
                }
                completion(.success(data))
            }
        case .post:
            request = makePOSTRequest(apiAble: apiAble)
        case .patch:
            request = makePATCHRequest(apiAble: apiAble)
        case .delete:
            request = makeDELETERequest(apiAble: apiAble)
        }
        
        if apiAble.method != .get {
            guard let request = request else {
                return
            }
            
            session.dataTask(with: request) { response in
                guard response.error == nil else {
                    completion(.failure(.error))
                    return
                }
                
                guard successRange.contains(response.statusCode) else {
                    completion(.failure(.statusCode))
                    return
                }
                
                guard let data = response.data else {
                    completion(.failure(.data))
                    return
                }
                completion(.success(data))
            }
        }
    }
}

// MARK: - POST
extension NetworkManager {
    private func generateBoundary() -> String {
        return "\(UUID().uuidString)"
    }
    
    mutating private func makePOSTRequest(apiAble: APIable) -> URLRequest? {
        let boundary = generateBoundary()
        
        if let item = apiAble.item {
            let urlString = apiAble.url + apiAble.path
            
            guard let url = URL(string: urlString) else {
                return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("multipart/form-data; boundary=\"\(boundary)\"",
                             forHTTPHeaderField: "Content-Type")
            request.addValue(UserInformation.identifier, forHTTPHeaderField: "identifier")
            request.addValue("eddy123", forHTTPHeaderField: "accessId")
            request.httpBody = createPOSTBody(requestInfo: item, boundary: boundary)
            
            return request
        } else {
            return makeSecretPOSTRequest(apiAble: apiAble)
        }
    }
    
    private func createPOSTBody(requestInfo: Item, boundary: String) -> Data? {
        var body: Data = Data()
        
        guard let jsonData = try? JSONEncoder().encode(requestInfo) else {
            return nil
        }
        
        guard let imageInfo = requestInfo.images else {
            return nil
        }
        
        body.append(convertDataToMultiPartForm(value: jsonData, boundary: boundary))
        body.append(convertFileToMultiPartForm(imageInfo: imageInfo, boundary: boundary))
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    
    private func convertDataToMultiPartForm(value: Data, boundary: String) -> Data {
        var data: Data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"params\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: application/json\r\n".data(using: .utf8)!)
        data.append("\r\n".data(using: .utf8)!)
        data.append(value)
        data.append("\r\n".data(using: .utf8)!)
        
        return data
    }
    
    private func convertFileToMultiPartForm(imageInfo: [ImageInfo], boundary: String) -> Data {
        var data: Data = Data()
        for imageInfo in imageInfo {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"images\"; filename=\"\(imageInfo.fileName)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: \(imageInfo.type.description)\r\n".data(using: .utf8)!)
            data.append("\r\n".data(using: .utf8)!)
            data.append(imageInfo.data)
            data.append("\r\n".data(using: .utf8)!)
        }
        
        return data
    }
    
    private func makeSecretPOSTRequest(apiAble: APIable) -> URLRequest? {
        guard let intId = apiAble.productId else {
            return nil
        }
        
        let productId = "/\(String(intId))"
        let secret = "/secret"
        let urlString = apiAble.url + apiAble.path + productId + secret

        guard let url = URL(string: urlString) else {
            return nil
        }
                
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(UserInformation.identifier, forHTTPHeaderField: "identifier")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"secret\": \"\(UserInformation.secret)\"}".data(using: .utf8)
        
        return request
    }
}

// MARK: - PATCH
extension NetworkManager {
    private func makePATCHRequest(apiAble: APIable) -> URLRequest? {
        guard let intId = apiAble.productId else {
            return nil
        }
        
        let productId = "/\(String(intId))"
        
        guard let url = URL(string: apiAble.url + apiAble.path + productId) else {
            return nil
        }
        
        guard let item = apiAble.item else {
            return nil
        }
                
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue(UserInformation.identifier, forHTTPHeaderField: "identifier")
        request.httpBody = createPATCHBody(requestInfo: item)
        
        return request
    }
    
    private func createPATCHBody(requestInfo: Item) -> Data? {
        return try? JSONEncoder().encode(requestInfo)
    }
}

// MARK: - DELETE
extension NetworkManager {
    private func makeDELETERequest(apiAble: APIable) -> URLRequest? {
        guard let intId = apiAble.productId else {
            return nil
        }
        guard let secret = apiAble.secret else {
            return nil
        }
        
        let productId = "/\(String(intId))"
        let productSecret = "/\(secret)"
        
        let urlString = apiAble.url + apiAble.path + productId + productSecret
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue(UserInformation.identifier, forHTTPHeaderField: "identifier")
        
        return request
    }
}
