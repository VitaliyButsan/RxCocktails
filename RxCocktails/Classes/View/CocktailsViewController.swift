//
//  ViewController.swift
//  RxCocktails
//
//  Created by Butsan Vitaliy on 15.06.2021.
//

import RxSwift
import RxDataSources
import MBProgressHUD
import SnapKit

class CocktailsViewController: UIViewController {
    
    let cocktailsViewModel: CocktailsViewModel
    
    private let bag = DisposeBag()
    
    init(viewModel: CocktailsViewModel) {
        self.cocktailsViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CocktailCell.self, forCellReuseIdentifier: CocktailCell.reuseID)
        return tableView
    }()
    
    private lazy var footerSpinner: UIActivityIndicatorView = {
        let spinnerView = UIActivityIndicatorView()
        spinnerView.hidesWhenStopped = true
        spinnerView.frame = CGRect(x: 0, y: 0, width: UIScreen.fullWidth, height: 60)
        return spinnerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        getData()
    }
    
    private func setup() {
        setupLayout()
        setupNavBar()
        showHUD()
        setupObservers()
        bindUI()
    }
    
    private func getData() {
        cocktailsViewModel.getData()
    }
    
    private func scrollToTop() {
        DispatchQueue.main.async {
            self.tableView.setContentOffset(.zero, animated: true)
        }
    }
    
    private func removeFooterSpinner() {
        DispatchQueue.main.async {
            self.tableView.tableFooterView = nil
        }
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(view)
        }
    }
    
    private func setupNavBar() {
        navigationItem.title = NSLocalizedString("Drinks", comment: "")
    }
    
    private func setupFiltersBarButton(showBadge: Bool) {
        let badgeSideSize: CGFloat = 10
        
        let badge = UIView(frame: CGRect(x: 17, y: -4, width: badgeSideSize, height: badgeSideSize))
        badge.backgroundColor = Constants.baidgeColor
        badge.clipsToBounds = true
        badge.isHidden = !showBadge
        badge.layer.cornerRadius = badgeSideSize / 2
        
        let button = UIButton()
        button.addSubview(badge)
        button.setImage(UIImage(named: "filter_icon"), for: .normal)
        button.addTarget(self, action: #selector(goToFiltersVC), for: .touchUpInside)
        
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButton
    }
    
    @objc private func goToFiltersVC() {
        cocktailsViewModel.setupFilters()
        let filtersVC = FiltersViewController(viewModel: cocktailsViewModel)
        navigationController?.pushViewController(filtersVC, animated: true)
    }
    
    private func showAlert(title: String, hideAfter: Int) {
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(hideAfter)) {
            alertController.dismiss(animated: true)
        }
    }
    
    private func setupObservers() {
        
        cocktailsViewModel.noMoreCocktails
            .subscribe(onNext: { noMore in
                if noMore {
                    self.removeFooterSpinner()
                    self.showAlert(title: NSLocalizedString("No More Cocktails!", comment: ""), hideAfter: 2)
                }
            })
            .disposed(by: bag)
        
        cocktailsViewModel.isLoadedData
            .subscribe(onNext: { isLoaded in
                if isLoaded {
                    DispatchQueue.main.async {
                        self.hideHUD()
                        self.footerSpinner.stopAnimating()
                    }
                }
            })
            .disposed(by: bag)
        
        cocktailsViewModel.hasFilters
            .subscribe(onNext: { hasFilters in
                if hasFilters {
                    self.scrollToTop()
                    self.removeFooterSpinner()
                }
                self.setupFiltersBarButton(showBadge: hasFilters)
            })
            .disposed(by: bag)
    }
    
    private func bindUI() {
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<Category, Cocktail>> { (dataSource, table, indexPath, cocktail) in
            let cell = self.tableView.dequeueReusableCell(withIdentifier: CocktailCell.reuseID, for: indexPath) as! CocktailCell
            cell.setupCell(with: cocktail)
            return cell
        }
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].model.name
        }
        
        cocktailsViewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        // pagination
        tableView.rx
            .willDisplayCell
            .subscribe(onNext: { cell, indexPath in
                self.getMoreCocktailsIfNeeded(for: indexPath)
            })
            .disposed(by: bag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: bag)
    }
    
    private func getMoreCocktailsIfNeeded(for indexPath: IndexPath) {
        if indexPath == tableView.lastIndexPath(),
           cocktailsViewModel.isLoadedData.value,
           !cocktailsViewModel.hasFilters.value,
           !cocktailsViewModel.noMoreCocktails.value {
            
            DispatchQueue.main.async {
                self.tableView.tableFooterView = self.footerSpinner
                self.footerSpinner.startAnimating()
                self.cocktailsViewModel.getMoreCocktails()
            }
        }
    }
}

// MARK: - table view delegate -

extension CocktailsViewController: UITableViewDelegate {
    
    private func setupSectionHeaderView(for section: Int) -> UIView {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: Constants.headerViewHeight))
        headerView.backgroundColor = Constants.headerBgColor
        
        let textLabel = UILabel()
        textLabel.font = Constants.headerTextFont
        textLabel.textColor = Constants.headerTextColor
        textLabel.text = cocktailsViewModel.sections.value[section].model.name.uppercased()
        
        headerView.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        let separator = UIView()
        separator.backgroundColor = Constants.separatorColor
        
        headerView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(headerView)
            make.height.equalTo(1)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return setupSectionHeaderView(for: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerViewHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.rowHeight
    }
}
