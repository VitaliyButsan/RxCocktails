//
//  Category.swift
//  RxCocktails
//
//  Created by Butsan Vitaliy on 15.06.2021.
//

import Foundation

struct CategoriesWrapper: Decodable {
    let drinks: [Category]
}

struct Category: Decodable, Hashable {
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name = "strCategory"
    }
}
