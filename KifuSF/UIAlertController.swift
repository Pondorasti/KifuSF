//
//  UIAlertController.swift
//  KifuSF
//
//  Created by Erick Sanchez on 7/29/18.
//  Copyright © 2018 Alexandru Turcanu. All rights reserved.
//

import UIKit.UIAlertController

extension UIAlertController {
    convenience init(title: String = "Oops!", errorMessage: String?, dismissTitle: String = "Dismiss") {
        self.init(
            title: title,
            message: "Something went wrong" + (errorMessage != nil ? ": \(errorMessage!)" : "."),
            preferredStyle: .alert
        )
        
        let dismissAction = UIAlertAction(title: dismissTitle, style: .default, handler: nil)
        self.addAction(dismissAction)
    }
    
    static func show(inViewController viewController: UIViewController, withTitle title: String = "Oops!", errorMessage: String?, dismissTitle: String = "Dismiss") {
        
        let ac = UIAlertController(title: title, errorMessage: errorMessage, dismissTitle: dismissTitle)
        viewController.present(ac, animated: true)
        
    }
    
    
}
