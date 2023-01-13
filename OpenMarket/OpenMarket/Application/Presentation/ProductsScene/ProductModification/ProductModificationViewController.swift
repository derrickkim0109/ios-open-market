//
//  ProductModificationViewController.swift
//  OpenMarket
//
//  Created by 데릭, 수꿍.
//

import UIKit

final class ProductModificationViewController: UIViewController {
    private let productEnrollmentView = ProductEnrollmentView()

    weak var delegate: ProductModificationDelegate?
    private let viewModel: ProductModificationViewModel
    private var modifyProductTask: Task<Void, Error>?

    init(viewModel: ProductModificationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        modifyProductTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func bind() {
        view.backgroundColor = .systemBackground
        view.addSubview(productEnrollmentView)
        configureNavigationItems()
        configureLayouts()
        bindViewModel()
    }

    private func bindViewModel() {
        updateUI(by: viewModel.fetchData())
    }

    private func configureLayouts() {
        NSLayoutConstraint.activate([
            productEnrollmentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            productEnrollmentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            productEnrollmentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            productEnrollmentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            productEnrollmentView.imageAndPickerButtonScrollView.heightAnchor.constraint(equalToConstant: view.layer.bounds.width * 0.3)
        ])
    }

    private func configureNavigationItems() {
        title = CurrentPage.productModification
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(didTapCancelButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(didTapDoneButton))
    }

    private func checkNumberOfText(in textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = .lightGray
            textView.text = ProductStatus.productDescription
        } else {
            textView.textColor = .black
        }
    }

    func updateUI(by data: ProductDetailsEntity) {
        productEnrollmentView.productNameTextField.text = data.name
        productEnrollmentView.originalPriceTextField.text = data.price.description
        productEnrollmentView.discountedPriceTextField.text = data.bargainPrice.description
        productEnrollmentView.productStockTextField.text = data.stock.description
        productEnrollmentView.productDescriptionTextView.text = data.description
        productEnrollmentView.currencySegmentedControl.selectedSegmentIndex = data.currency == .krw ? 0 : 1
        configureNewImageView(data.images)
        checkNumberOfText(in: productEnrollmentView.productDescriptionTextView)
    }

    private func configureProfileImageView(with imageURL: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.setImageUrl(imageURL)

        return imageView
    }

    private func configureNewImageView(_ imagesURL: [String]) {
        imagesURL.forEach { image in
            let imageView = configureProfileImageView(with: image)

            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
            ])

            productEnrollmentView.imageStackView.addArrangedSubview(imageView)
        }
    }

    // MARK: - Action

    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }

    @objc private func didTapDoneButton() {
        modifyProductTask = Task {
            await viewModel.didSelectCompletionButton(input: productEnrollmentView.convertTextToTypeDTO())
            guard let state = viewModel.state else { return }
            switch state {
            case .failed(let error):
                self.presentConfirmAlert(message: error.localizedDescription)
            }
        }
    }
}