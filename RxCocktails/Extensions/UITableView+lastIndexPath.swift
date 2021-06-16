//
//  UITableView+lastIndexPath.swift
//  RxCocktails
//
//  Created by Butsan Vitaliy on 16.06.2021.
//

import UIKit

extension UITableView {
    
    func lastIndexPath() -> IndexPath {
        let lastSection = max(numberOfSections - 1, 0)
        let lastRow = max(numberOfRows(inSection: lastSection) - 1, 0)
        return IndexPath(row: lastRow, section: lastSection)
    }
}
