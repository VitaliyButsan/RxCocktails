//
//  UIViewController+progressHUD.swift
//  RxCocktails
//
//  Created by Butsan Vitaliy on 16.06.2021.
//

import Foundation
import MBProgressHUD

extension UIViewController {
    
    func hideHUD() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func showHUD(_ message: String) {
        let progressHUD: MBProgressHUD
        progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHUD.label.text = message
    }
}
