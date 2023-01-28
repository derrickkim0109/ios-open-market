//
//  LoadingIndicator.swift
//  OpenMarket
//
//  Created by 데릭, 수꿍.
//

import UIKit

@MainActor
class LoadingIndicator {
    static func presentLoading() async {
        guard let window = UIApplication.shared.windows.last else {
            return
        }

        let loadingIndicatorView: UIActivityIndicatorView

        if let existedView = window.subviews.first(
            where: { $0 is UIActivityIndicatorView } ) as? UIActivityIndicatorView {
            loadingIndicatorView = existedView
        } else {
            loadingIndicatorView = UIActivityIndicatorView(
                style: .large)
            
            loadingIndicatorView.frame = window.frame
            loadingIndicatorView.color = .brown
            window.addSubview(loadingIndicatorView)
        }

        loadingIndicatorView.startAnimating()
    }
    
    static func hideLoading() async {
        guard let window = UIApplication.shared.windows.last else {
            return
        }
        
        window.subviews.filter({ $0 is UIActivityIndicatorView }).forEach { $0.removeFromSuperview() }
    }
}
