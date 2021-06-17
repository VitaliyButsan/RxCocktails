//
//  Category.swift
//  RxCocktails
//
//  Created by Butsan Vitaliy on 15.06.2021.
//

struct CategoriesWrapper: Decodable {
    let drinks: [Category]
}

struct Category: Decodable, Hashable {
    let name: String
    var isSelected = false
    
    enum CodingKeys: String, CodingKey {
        case name = "strCategory"
    }
}

