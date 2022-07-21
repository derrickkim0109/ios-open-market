//
//  NetworkProvider.swift
//  OpenMarket
//
//  Created by 데릭, 케이, 수꿍. 
//

import Foundation

class NetworkProvider {
    var session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func requestAndDecode<T: Codable>(url: String,
                                      dataType: T.Type,
                                      completion: @escaping (Result<T,NetworkError>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let dataTask: URLSessionDataTaskProtocol = session.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(.unknownErrorOccured))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               (200..<300).contains(response.statusCode),
               let verifiedData = data {
                do {
                    let decodedData = try JSONDecoder().decode(T.self,
                                                               from: verifiedData)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(.failedToDecode))
                }
            } else {
                completion(.failure(.networkConnectionIsBad))
            }
        }
        dataTask.resume()
    }
}
