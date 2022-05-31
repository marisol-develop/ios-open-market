//
//  NetworkManager.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/05/10.
//

import Foundation

enum NetworkError: Error {
    case error
    case data
    case statusCode
    case decode
    case request
}

struct ImageInfo {
    let fileName: String
    let data: Data
    let type: String
}

struct NetworkManager<T: Decodable> {
    private var session: URLSessionProtocol
    
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
    mutating func execute(with endPoint: Endpoint, httpMethod: HTTPMethod, params: Encodable? = nil, images: [ImageInfo]? = nil, completion: @escaping (Result<T, NetworkError>) -> Void) {
        let successRange = 200...299
        
        switch httpMethod {
        case .get:
            session.dataTask(with: endPoint) { response in
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
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(T.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(.decode))
                }
            }       
        case .post:
            guard let params = params as? PostRequest,
                  let images = images else {
                      completion(.failure(.data))
                      return
                  }

            guard let request = requestPOST(endPoint: endPoint, params: params, images: images) else {
                completion(.failure(.request))
                return
            }
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    completion(.failure(.error))
                    return
                }
                
                guard let _ = data else {
                    completion(.failure(.data))
                    return
                }
                
                guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                    completion(.failure(.statusCode))
                    return
                }
            }.resume()
            
        case .patch:
            guard let params = params as? PatchRequest else {
                completion(.failure(.data))
                return
            }

            guard let request = requestPATCH(endPoint: endPoint, params: params) else {
                completion(.failure(.request))
                return
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    completion(.failure(.error))
                    return
                }
                
                guard let _ = data else {
                    completion(.failure(.data))
                    return
                }
                
                guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                    print("hello")
                    completion(.failure(.statusCode))
                    return
                }
            }.resume()
            
        case .delete:
            print("delete")
        }
    }
}

// MARK: - POST
extension NetworkManager {
    private func generateBoundary() -> String {
        return "\(UUID().uuidString)"
    }

    mutating private func requestPOST(endPoint: Endpoint, params: PostRequest, images: [ImageInfo]) -> URLRequest? {
        let boundary = generateBoundary()
        
        guard let url = endPoint.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("multipart/form-data; boundary=\"\(boundary)\"",
                         forHTTPHeaderField: "Content-Type")
        request.addValue(UserInformation.identifer, forHTTPHeaderField: "identifier")
        request.addValue("eddy123", forHTTPHeaderField: "accessId")
        request.httpBody = createPOSTBody(requestInfo: params, images: images, boundary: boundary)

        return request
    }

    private func createPOSTBody(requestInfo: PostRequest, images: [ImageInfo], boundary: String) -> Data? {
        var body: Data = Data()
                        
        guard let jsonData = try? JSONEncoder().encode(requestInfo) else {
            return nil
        }
        
        body.append(convertDataToMultiPartForm(value: jsonData, boundary: boundary))
        body.append(convertFileToMultiPartForm(imageInfo: images, boundary: boundary))
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
}

// MARK: - PATCH
extension NetworkManager {
    private func createPATCHBody(requestInfo: PatchRequest) -> Data? {        
        return try? JSONEncoder().encode(requestInfo)
    }
    
    private func requestPATCH(endPoint: Endpoint, params: PatchRequest) -> URLRequest? {
        guard let url = endPoint.url else {
            return nil
        }
                
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue(UserInformation.identifer, forHTTPHeaderField: "identifier")
        request.httpBody = createPATCHBody(requestInfo: params)
        
        return request
    }
}
