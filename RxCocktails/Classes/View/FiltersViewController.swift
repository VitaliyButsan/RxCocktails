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
    
    private var isButtonHighlighted = false
    
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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    var applyFiltersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Apply Filters", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        viewModel.setupSections()
        setupLayout()
        //setupNavBar()
        setupObservers()
        bindUI()
    }
    
    private func setupLayout() {
        [tableView,
         applyFiltersButton].forEach { view.addSubview($0) }
        
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(self.view)
        }
        
        applyFiltersButton.snp.makeConstraints { make in
            make.leading.equalTo(self.view.snp.leading).inset(16)
            make.trailing.equalTo(self.view.snp.trailing).inset(16)
            make.bottom.equalTo(self.view.snp.bottom).inset(16 * 2)
            make.height.equalTo(50)
        }
    }
    
    private func setupObservers() {
        applyFiltersButton.rx.tap
            .bind(to: viewModel.applyFiltersSbj)
            .disposed(by: bag)
    }
    
    private func bindUI() {
        
        viewModel.filters
            .bind(to: tableView.rx.items(cellIdentifier: FilterCell.reuseID, cellType: FilterCell.self)) { index, section, cell in
                cell.categoryLabel.text = section.model.name
                cell.checkmark.isHidden = !(section.model.isSelected ?? false)
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
