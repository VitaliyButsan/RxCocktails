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
    private(set) var filters = BehaviorRelay(value: [SectionModel<Category, Cocktail>]())
    private(set) var isLoaded = BehaviorRelay(value: false)
    private(set) var hasFilters = BehaviorRelay(value: false)
    private(set) var noMoreCocktails = BehaviorRelay(value: false)
    
    private var allCategories: [Category] = []
    
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
        filters.accept(filters.value + [section])
        sections.accept(sections.value + [section])
    }
    
    func setSelected(category: Category) {
        guard let index = filters.value.firstIndex(where: { $0.model.name == category.name }) else { return }
        var tempFilters = filters.value
        tempFilters[index].model.isSelected?.toggle()
        filters.accept(tempFilters)
    }
    
    private func applyFilters() {
        hasFilters.accept(filters.value.contains(where: { $0.model.isSelected == true }))
        let filteredSections = filters.value.filter { $0.model.isSelected == true }
        sections.accept(hasFilters.value ? filteredSections : filters.value)
    }
    
    func setupSections() {
        // remove all selected
        for index in filters.value.indices {
            var tempFilters = filters.value
            tempFilters[index].model.isSelected = false
            filters.accept(tempFilters)
        }
        // set selected
        for section in sections.value {
            if section.model.isSelected == true {
                guard let index = filters.value.firstIndex(where: { $0.model.name == section.model.name }) else {return}
                var tempFilters = filters.value
                tempFilters[index].model.isSelected = true
                filters.accept(tempFilters)
            }
        }
    }
}
