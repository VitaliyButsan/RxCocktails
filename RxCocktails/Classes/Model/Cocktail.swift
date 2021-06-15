//
//  Cocktail.swift
//  RxCocktails
//
//  Created by Butsan Vitaliy on 15.06.2021.
//

import Foundation

struct CocktailsWrapper: Decodable {
    let drinks: [Cocktail]
}

struct Cocktail: Decodable {
    let name: String?
    let thumbLink: String?
    let idDrink: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "strDrink"
        case thumbLink = "strDrinkThumb"
        case idDrink
    }
}
