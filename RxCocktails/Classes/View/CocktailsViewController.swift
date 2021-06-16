//
//  ViewController.swift
//  RxCocktails
//
//  Created by Butsan Vitaliy on 15.06.2021.
//

import SwiftUI
import RxSwift
import SnapKit
import RxDataSources
import MBProgressHUD

class CocktailsViewController: UIViewController {
    
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinnerView = UIActivityIndicatorView()
        spinnerView.hidesWhenStopped = true
        spinnerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 60)
        return spinnerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        getData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //setupFilterBarButton()
    }
    
    private func setupFilterBarButton(showBadge: Bool) {
        let badgeSideSize: CGFloat = 10
        let badge = UIView(frame: CGRect(x: 17, y: -4, width: badgeSideSize, height: badgeSideSize))
        badge.backgroundColor = #colorLiteral(red: 0.9156965613, green: 0.380413115, blue: 0.2803866267, alpha: 1)
        badge.clipsToBounds = true
        badge.isHidden = !showBadge
        badge.layer.cornerRadius = badgeSideSize / 2
        
        let button = UIButton()
        button.setImage(UIImage(named: "filter_icon"), for: .normal)
        button.addSubview(badge)
        button.addTarget(self, action: #selector(goToFilters), for: .touchUpInside)
        
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func goToFilters() {
        let filtersVC = FiltersViewController(viewModel: viewModel)
        navigationController?.pushViewController(filtersVC, animated: true)
    }
    
    private func setup() {
        setupLayout()
        setupNavBar()
        setupObservers()
        bindUI()
    }
    
    private func getData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.viewModel.getData()
        }
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(self.view)
        }
        tableView.tableFooterView = spinner
    }
    
    private func setupNavBar() {
        navigationItem.title = "Drinks"
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "No more cocktails!", message: "", preferredStyle: .alert)
        self.present(alertController, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alertController.dismiss(animated: true)
        }
    }
    
    private func setupObservers() {
        if viewModel.sections.value.isEmpty {
            showHUD("Loading...")
        }
        
        viewModel.noMoreCocktails
            .subscribe(onNext: { noMore in
                if noMore {
                    self.showAlert()
                }
            })
            .disposed(by: bag)
        
        viewModel.isLoaded
            .subscribe(onNext: { isLoaded in
                if isLoaded {
                    self.hideHUD()
                    self.spinner.stopAnimating()
                    self.tableView.tableFooterView = UIView()
                }
            })
            .disposed(by: bag)
        
        viewModel.hasFilters
            .subscribe(onNext: { hasFilters in
                self.setupFilterBarButton(showBadge: hasFilters)
            })
            .disposed(by: bag)
    }
    
    private func bindUI() {
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<Category, Cocktail>> { (dataSource, table, indexPath, cocktail) in
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = cocktail.name
            return cell
        }
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].model.name
        }
        
        viewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        // pagination logic
        tableView.rx
            .willDisplayCell
            .subscribe(onNext: { cell, indexPath in
                if indexPath == self.tableView.lastIndexPath() {
                    self.spinner.startAnimating()
                    self.viewModel.getMoreCocktails()
                }
            })
            .disposed(by: bag)
    }
}
