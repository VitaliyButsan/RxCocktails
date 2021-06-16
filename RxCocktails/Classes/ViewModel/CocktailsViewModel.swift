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
    
    let applyFiltersSbj = PublishSubject<Void>()
    
    private(set) var sections = BehaviorRelay(value: [SectionModel<Category, Cocktail>]())
    private(set) var isLoaded = BehaviorRelay(value: false)
    private(set) var hasFilters = BehaviorRelay(value: false)
    private(set) var noMoreCocktails = BehaviorRelay(value: false)
    
    private var allCategories: [Category] = []
    private var loadedSections: [SectionModel<Category, Cocktail>] = []
    
    private let netManager = CocktailsNetManager.instance
    private let bag = DisposeBag()
    
    init() {
        setupObservables()
    }

    private func setupObservables() {
        applyFiltersSbj
            .subscribe(onNext: { [weak self] _ in
                self?.applyFilters()
            })
            .disposed(by: bag)
    }
    
    func getData() {
        netManager.getCategories().subscribe { [weak self] event in
            switch event {
            case .success(let categories):
                self?.allCategories = categories
                self?.getMoreCocktails()
            case .error(let error):
                print(error)
            }
        }
        .disposed(by: bag)
    }
    
    func getMoreCocktails() {
        for category in allCategories {
            if !sections.value.contains(where: { $0.model == category }) {
                isLoaded.accept(false)
                getCocktails(by: category)
                break
            } else {
                if category == allCategories.last, noMoreCocktails.value == false {
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
        let section = SectionModel(model: category, items: cocktails)
        loadedSections.append(section)
        self.sections.accept(loadedSections)
    }
    
    func setSelected(category: Category) {
        guard let index = loadedSections.firstIndex(where: { $0.model.name == category.name }) else { return }
        loadedSections[index].model.isSelected?.toggle()
    }
    
    private func applyFilters() {
        hasFilters.accept(loadedSections.contains(where: {$0.model.isSelected == true}))
        sections.accept(loadedSections)
    }
    
    func setupSections() {
        loadedSections = sections.value
    }
}
