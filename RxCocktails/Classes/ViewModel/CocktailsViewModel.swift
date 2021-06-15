//
//  CocktailsViewModel.swift
//  RxCocktails
//
//  Created by Butsan Vitaliy on 15.06.2021.
//

import RxSwift
import RxCocoa
import RxDataSources
import Moya

class CocktailsViewModel {
    
    private(set) var sections = BehaviorRelay(value: [SectionModel<Category, Cocktail>]())
    
    private var categories: [Category] = []
    private var cocktailsWithCategories: [Category : [Cocktail]] = [:]
    
    private let netManager = CocktailsNetManager.instance
    private let bag = DisposeBag()
    
    func getData() {
        getCategories()
    }
    
    private func getCategories() {
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
        let group = DispatchGroup()
        
        for category in categories {
            group.enter()
            netManager.getCocktails(by: category).subscribe { [weak self] event in
                switch event {
                case .success(let cocktails):
                    self?.cocktailsWithCategories[category] = cocktails
                    group.leave()
                case .error(let error):
                    print(error)
                }
            }
            .disposed(by: bag)
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.createSections(by: categories)
        }
    }
    
    func createSections(by categories: [Category]) {
        var models: [SectionModel<Category, Cocktail>] = []
        
        for category in categories {
            guard let cocktails = cocktailsWithCategories[category] else { return }
            let model = SectionModel(model: category, items: cocktails)
            models.append(model)
        }
        sections.accept(models)
    }
}
