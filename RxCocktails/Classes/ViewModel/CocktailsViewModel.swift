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
    private(set) var isLoaded = BehaviorRelay(value: false)
    private(set) var hasFilters = BehaviorRelay(value: false)
    private(set) var noMoreCocktails = BehaviorRelay(value: false)
    
    private var categories: [Category] = []
    
    private let netManager = CocktailsNetManager.instance
    private let bag = DisposeBag()
    
    func getData() {
        netManager.getCategories().subscribe { [weak self] event in
            switch event {
            case .success(let categories):
                self?.categories = categories
                self?.getMoreCocktails()
            case .error(let error):
                print(error)
            }
        }
        .disposed(by: bag)
    }
    
    func getMoreCocktails() {
        for category in categories {
            if !sections.value.contains(where: { $0.model == category }) {
                isLoaded.accept(false)
                getCocktails(by: category)
                break
            } else {
                if category == categories.last, noMoreCocktails.value == false {
                    noMoreCocktails.accept(true)
                }
            }
        }
    }
    
    private func getCocktails(by category: Category) {
        netManager.getCocktails(by: category).subscribe { [weak self] event in
            switch event {
            case .success(let cocktails):
                self?.save(cocktails, by: category)
                self?.isLoaded.accept(true)
            case .error(let error):
                print(error)
            }
        }
        .disposed(by: bag)
    }
    
    private func save(_ cocktails: [Cocktail], by category: Category) {
        var sections = self.sections.value
        let section = SectionModel(model: category, items: cocktails)
        sections.append(section)
        self.sections.accept(sections)
    }
    
    func setSelected(category: Category) {
        var sections = self.sections.value
        guard let sectionIndex = self.sections.value.firstIndex(where: { $0.model == category }) else { return }
        sections[sectionIndex].model.isSelected?.toggle()
        hasFilters.accept(sections.contains(where: {$0.model.isSelected == true}))
        self.sections.accept(sections)
    }
}
