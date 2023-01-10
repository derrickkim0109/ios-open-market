//
//  DefaultProductDetailsViewModel.swift
//  OpenMarket
//
//  Created by 데릭, 수꿍.
//

import UIKit

final class DefaultProductDetailsViewModel: ProductDetailsViewModel {
    private let fetchProductDetailsUseCase: FetchProductDetailsUseCase
    private let actions: ProductDetailsViewModelActions?

    // MARK: Output
    var loading: ProductsListViewModelLoading?
    var state: ProductDetailsState?

    private var productDetailsEntity: ProductDetailsEntity?
    private var currentPage: Int?
    
    init(fetchProductDetailsUseCase: FetchProductDetailsUseCase,
         actions: ProductDetailsViewModelActions? = nil) {
        self.fetchProductDetailsUseCase = fetchProductDetailsUseCase
        self.actions = actions
    }
    
    func returnCurrentpage(_ index: Int){
        currentPage = index
    }

    func transform(input: Int) async {
        do {
            let data = try await load(productID: input)
            let formattedData = format(productDetails: data)
            productDetailsEntity = formattedData
            state = .success(data: formattedData)
        } catch (let error) {
            state = .failed(error: error)
        }
    }
    
    private func load(productID: Int) async throws -> ProductDetailsResponseDTO {
        do {
            let result = try await fetchProductDetailsUseCase.execute(productID: productID)
            return result
        } catch (let error) {
            throw error
        }
    }

    private func format(productDetails: ProductDetailsResponseDTO) -> ProductDetailsEntity {
        let productInfo = productDetails.toDomain()
        return productInfo
    }
}

extension DefaultProductDetailsViewModel {
    func didSelectEditButton() {
        guard let model = productDetailsEntity else { return }
        actions?.presentProductModitifation(model)
    }

    func didDeleteProducts(_ productID: Int) {

    }
}