//
//  ProductModificationViewModel.swift
//  OpenMarket
//
//  Created by Derrick kim on 2023/01/13.
//

protocol ProductModificationViewModelInput {
    func didSelectModificationButton(
        input: TypedProductDetailsRequestDTO) async
    func didTapCancelButton()
    func fetchData() -> ProductDetailsEntity
    func dismissScene()
}

protocol ProductModificationViewModelOutput {
    var state: ProductModificationState? { get }
}

enum ProductModificationState {
    case success
    case failed(error: String)
}

protocol ProductModificationViewModel: ProductModificationViewModelInput, ProductModificationViewModelOutput {}
