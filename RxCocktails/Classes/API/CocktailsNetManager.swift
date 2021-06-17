//
//  CocktailsNetManager.swift
//  RxCocktails
//
//  Created by Butsan Vitaliy on 15.06.2021.
//

import Moya
import RxSwift

class CocktailsNetManager {
    
    static let instance = CocktailsNetManager()
    
    private init() { }
    
    private let provider = MoyaProvider<CocktailsService>()
    
    func getCategories() -> Single<[Category]> {
        provider.rx
            .request(.getCategories)
            .filterSuccessfulStatusAndRedirectCodes()
            .map(CategoriesWrapper.self)
            .map(\.drinks)
    }
    
    func getCocktails(by category: Category) -> Single<[Cocktail]> {
        provider.rx
            .request(.filterCocktails(by: category.name))
            .filterSuccessfulStatusCodes()
            .map(CocktailsWrapper.self)
            .map(\.drinks)
    }
}
