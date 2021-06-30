//
//  CocktailsViewModel.swift
//  RxCocktails
//
//  Created by Butsan Vitaliy on 15.06.2021.
//

import RxSwift
import RxCocoa
import RxDataSources

class CocktailsViewModel {
    
    // managers
    private let netManager = CocktailsNetManager.instance
    private let bag = DisposeBag()
    
    // state
    private(set) var isEnableApplyFiltersButton = BehaviorRelay(value: false)
    private(set) var isLoadedData = BehaviorRelay(value: false)
    private(set) var hasFilters = BehaviorRelay(value: false)
    private(set) var noMoreCocktails = BehaviorRelay(value: false)
    
    // storage
    private(set) var sections = BehaviorRelay(value: [SectionModel<Category, Cocktail>]())
    private(set) var filters = BehaviorRelay(value: [SectionModel<Category, Cocktail>]())
    private var allCategories: [Category] = []
    
    init() {
        subscribeObservables()
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
            if !sections.value.contains(where: { $0.model.name == category.name }) {
                isLoadedData.accept(false)
                getCocktails(by: category)
                break
            } else {
                if category == allCategories.last, !noMoreCocktails.value {
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
                self?.isLoadedData.accept(true)
            case .error(let error):
                print(error)
            }
        }
        .disposed(by: bag)
    }
    
    private func save(_ cocktails: [Cocktail], by category: Category) {
        let newSection = SectionModel(model: category, items: cocktails)
        sections.accept(sections.value + [newSection])
        filters.accept(sections.value)
    }
    
    private func subscribeObservables() {
        Observable.combineLatest(sections, filters) { (sections, filters) in
            sections.filter{$0.model.isSelected} == filters.filter{$0.model.isSelected}
        }
        .subscribe(onNext: { [weak self] isOn in
            self?.isEnableApplyFiltersButton.accept(isOn)
        })
        .disposed(by: bag)
    }
    
    func setSelected(category: Category) {
        guard let index = filters.value.firstIndex(where: { $0.model.name == category.name }) else { return }
        var tmpFilters = filters.value
        tmpFilters[index].model.isSelected.toggle()
        filters.accept(tmpFilters)
    }
    
    func applyFilters() {
        hasFilters.accept(filters.value.contains { $0.model.isSelected })
        let filteredSections = filters.value.filter { $0.model.isSelected }
        sections.accept(hasFilters.value ? filteredSections : filters.value)
    }
    
    func setupFilters() {
        // reset all filters
        for index in filters.value.indices {
            var tmpFilters = filters.value
            tmpFilters[index].model.isSelected = false
            filters.accept(tmpFilters)
        }
        // set needed filters
        for section in sections.value {
            if section.model.isSelected {
                guard let index = filters.value.firstIndex(where: { $0.model.name == section.model.name }) else { return }
                var tmpFilters = filters.value
                tmpFilters[index].model.isSelected = true
                filters.accept(tmpFilters)
            }
        }
    }
}
