//
//  ProductDeleteAPIManager.swift
//  OpenMarket
//
//  Created by 데릭, 수꿍.
//

import Foundation

struct ProductDeleteAPIManager: DELETEProtocol {
    var configuration: APIConfiguration
    var urlComponent: URLComponents
    
    init?(productID: Int, productSecret: String) {
        urlComponent = URLComponentsBuilder()
            .setScheme("https")
            .setHost("openmarket.yagom-academy.kr")
            .setPath("/api/products/\(productID)/\(productSecret)")
            .build()
        
        guard let url = urlComponent.url else {
            return nil
        }
        
        configuration = APIConfiguration(url: url)
    }
}
