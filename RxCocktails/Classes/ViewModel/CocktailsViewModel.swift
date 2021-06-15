//
//  CocktailsViewModel.swift
//  RxCocktails
//
//  Created by Butsan Vitaliy on 15.06.2021.
//

import RxSwift
import Moya

class CocktailsViewModel {
    
    private var categories: [Category] = []
    private var cocktailsWithCategories: [Category : [Cocktail]] = [:]
    
    private let netManager = CocktailsNetManager.instance
    private let bag = DisposeBag()
    
    func getCategories() {
        netManager.getCategories().subscribe { [weak self] event in
            switch event {
            case .success(let categories):
                self?.categories = categories
                self?.getCocktails(by: categories)
            case .error(let error):
                print(error)
            }
        }
        .disposed(by: bag)
    }
    
    private func getCocktails(by categories: [Category]) {
        var result: [Category:[Cocktail]] = [:]
        let group = DispatchGroup()
        
        for category in categories {
            group.enter()
            netManager.getCocktails(by: category).subscribe { event in
                switch event {
                case .success(let cocktails):
                    result[category] = cocktails
                    group.leave()
                case .error(let error):
                    print(error)
                }
            }
            .disposed(by: bag)
        }
        
        group.notify(queue: DispatchQueue.main) {
            result.forEach { print("-->", $0.key.name) }
        }
    }
}
