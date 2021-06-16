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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        //getData()
    }
    
    private func setup() {
        setupLayout()
        //setupNavBar()
        //setupObservers()
        bindUI()
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(self.view)
        }
    }
    
    private func bindUI() {
        
        viewModel.sections
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
        
        /*tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                let cell = self?.tableView.cellForRow(at: indexPath) as? FilterCell
                //cell?.checkmark.isHidden.toggle()
                //viewModel.setSelected(category: <#T##Category#>)
            })
            .disposed(by: bag)*/
    }
}
