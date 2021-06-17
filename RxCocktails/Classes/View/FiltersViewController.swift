//
//  FiltersViewController.swift
//  RxCocktails
//
//  Created by Butsan Vitaliy on 16.06.2021.
//

import UIKit
import RxSwift
import RxDataSources
import SnapKit

class FiltersViewController: UIViewController {
    
    let viewModel: CocktailsViewModel
    
    private let bag = DisposeBag()
    
    init(viewModel: CocktailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.reuseID)
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private lazy var applyFiltersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Apply Filters", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        viewModel.setupSections()
        setupLayout()
        setupNavBar()
        setupObservers()
        bindUI()
    }
    
    private func setupLayout() {
        [tableView,
         applyFiltersButton].forEach { view.addSubview($0) }
        
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(view)
        }
        
        applyFiltersButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view).inset(Constants.defaultPadding * 2)
            make.height.equalTo(50)
        }
    }
    
    private func setupNavBar() {
        navigationItem.title = "Filters"
        navigationController?.navigationBar.tintColor = .black
    }
    
    private func setupObservers() {
        
        applyFiltersButton.rx.tap
            .bind(to: viewModel.applyFiltersSbj)
            .disposed(by: bag)
        
        applyFiltersButton.rx.tap
            .bind {
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: bag)
        
        let enableButton = Observable<Bool>.combineLatest(viewModel.sections, viewModel.filters) { (sections,filters) in
            let selectedSections = sections.filter { $0.model.isSelected }
            let selectedFilters = filters.filter { $0.model.isSelected }
            return selectedSections != selectedFilters
        }
        
        enableButton
            .bind(to: applyFiltersButton.rx.isEnabled)
            .disposed(by: bag)
    }
    
    private func bindUI() {
        
        viewModel.filters
            .bind(to: tableView.rx.items(cellIdentifier: FilterCell.reuseID, cellType: FilterCell.self)) { index, section, cell in
                cell.categoryLabel.text = section.model.name
                cell.checkmark.isHidden = !section.model.isSelected
                cell.selectionStyle = .none
            }
            .disposed(by: bag)
        
        tableView.rx.modelSelected(SectionModel<Category, Cocktail>.self)
            .subscribe(onNext: { [weak self] category in
                self?.viewModel.setSelected(category: category.model)
            })
            .disposed(by: bag)
    }
}
