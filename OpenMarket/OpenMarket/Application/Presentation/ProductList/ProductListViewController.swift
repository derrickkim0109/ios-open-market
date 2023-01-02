//
//  OpenMarket - ProductListViewController.swift
//  Created by 데릭, 수꿍.
//  Copyright © yagom. All rights reserved.
//

import UIKit
import Combine

final class ProductListViewController: UIViewController {
    enum Const {
        static let borderWidthOnePoint: CGFloat = 1.0
        static let cornerRadiusTenPoint: CGFloat = 10.0
        static let plus = "+"
        static let one = 1
        static let hundred: CGFloat = 100
    }

    enum ListSection {
        case main
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<ListSection, ProductEntity>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<ListSection, ProductEntity>

    private var initialPageInfo: (pageNumber: Int, itemsPerPage: Int) = (RequestName.initialPageNumber,
                                                                         RequestName.initialItemPerPage)
    private let viewModel: ProductListViewModelImpl
    private var productListTask: Task<Void, Error>?

    private lazy var dataSource = configureDataSource()
    private var snapshot = Snapshot()

    private lazy var productListView: ProductListView = {
        let view = ProductListView()
        return view
    }()

    init(viewModel: ProductListViewModelImpl) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        productListTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func bind() {
        view.backgroundColor = .white
        view.addSubview(productListView)
        productListView.collectionView.delegate = self

        configureLayouts()
        setupNavigationItems()
        configureRefreshControl()

        bindData(by: ProductListViewModelImpl.Input(productListTrigger: initialPageInfo))
    }

    func bindData(by input: ProductListViewModelImpl.Input) {
        productListTask = Task {
            let output = await viewModel.transform(input: input)
            await LoadingIndicator.hideLoading()

            guard let state = output.state else { return }
            switch state {
            case .success(let data):
                applySnapshot(by: data)
            case .failed(let error):
                presentConfirmAlert(message: error.localizedDescription)
            }
        }
    }

    private func configureLayouts() {
        NSLayoutConstraint.activate([
            productListView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            productListView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            productListView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            productListView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func configureDataSource() -> DataSource {
        let cellRegistration = UICollectionView.CellRegistration<ProductListCollectionCell, ProductEntity> { cell, indexPath, item in
            cell.layer.borderColor = UIColor.systemGray.cgColor
            cell.layer.borderWidth = Const.borderWidthOnePoint
            cell.layer.cornerRadius = Const.cornerRadiusTenPoint

            cell.updateUI(item)
        }

        return UICollectionViewDiffableDataSource<ListSection, ProductEntity>(collectionView: productListView.collectionView) { (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell? in

            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                for: indexPath,
                                                                item: itemIdentifier)
        }
    }
    
    private func setupNavigationItems() {
        navigationItem.rightBarButtonItem  = UIBarButtonItem(title: Const.plus,
                                                             style: .plain,
                                                             target: self,
                                                             action: #selector(addButtonTapped(_:)))
    }

    @MainActor
    private func applySnapshot(by data: [ProductEntity]) {
        if initialPageInfo.pageNumber == RequestName.initialPageNumber {
            snapshot.deleteAllItems()
            snapshot.appendSections([.main])
        }

        snapshot.appendItems(data)
        dataSource.apply(snapshot,
                         animatingDifferences: false)
    }
    
    private func configureRefreshControl() {
        productListView.collectionView.refreshControl = UIRefreshControl()
        productListView.collectionView.refreshControl?.addTarget(self,
                                                            action:#selector(didSetRefreshControl),
                                                            for: .valueChanged)
    }
    
    private func resetData() {
        initialPageInfo = (RequestName.initialPageNumber, RequestName.initialItemPerPage)
        bindData(by: ProductListViewModelImpl.Input(productListTrigger: initialPageInfo))
        productListView.collectionView.refreshControl?.endRefreshing()
    }
    
    @objc private func didSetRefreshControl() {
        resetData()
    }

    @objc private func addButtonTapped(_ sender: UIBarButtonItem) {
        let productEnrollmentViewController = ProductEnrollmentViewController()
        present(viewController: productEnrollmentViewController)
    }
}

extension ProductListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let product = dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath,
                                        animated: true)
            return
        }
        
        let productDetailViewController: ProductDetailsViewController = {
            let viewController = ProductDetailsViewController()
            viewController.productID = product.id
            viewController.productVendorID = product.vendorID
            viewController.title = product.name
            return viewController
        }()
        
        navigationController?.pushViewController(productDetailViewController,
                                                 animated: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        reloadDataDidScrollDown(productListView.collectionView)
    }
    
    private func reloadDataDidScrollDown(_ collectionView: UICollectionView) {
        let trigger = (collectionView.contentSize.height - collectionView.bounds.size.height) + Const.hundred
        
        if collectionView.contentOffset.y > trigger {
            initialPageInfo = (initialPageInfo.pageNumber + Const.one, RequestName.initialItemPerPage)
            bindData(by: ProductListViewModelImpl.Input(productListTrigger: initialPageInfo))
        }
    }
}
