//
//  UIViewController+Extensions.swift
//  OpenMarket
//
//  Created by 데릭, 수꿍.
//

import UIKit

extension UIViewController {
    func presentConfirmAlert(message: String) {
        let alertController = UIAlertController(title: AlertSetting.controller.title,
                                                message: message,
                                                preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: AlertSetting.confirmAction.title,
                                          style: .default) { [weak self] _ in
            
            
            if message == AlertMessage.enrollmentSuccess
                || message == AlertMessage.modificationSuccess {
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                }
            } else if message == AlertMessage.deleteSuccess {
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        alertController.addAction(confirmAction)
        
        present(alertController,
                animated: false)
    }
    
    func present(viewController: UIViewController) {
        let rootViewController = UINavigationController(rootViewController: viewController)
        rootViewController.modalPresentationStyle = .fullScreen
        
        present(rootViewController, animated: true)
    }
}


