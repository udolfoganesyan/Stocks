//
//  UIViewController+Alert.swift
//  Stocks
//
//  Created by Rudolf Oganesyan on 29.08.2020.
//  Copyright © 2020 Рудольф О. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showErrorOkAlert(_ message: String?) {
        showOkAlert("Error", message)
    }
    
    func showOkAlert(_ title: String?, _ message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        })
        self.present(alertController, animated: true)
    }
}
