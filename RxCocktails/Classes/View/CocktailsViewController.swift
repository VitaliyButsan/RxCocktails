//
//  ViewController.swift
//  RxCocktails
//
//  Created by Butsan Vitaliy on 15.06.2021.
//

import SwiftUI
import RxSwift
import RxDataSources
import MBProgressHUD
import SnapKit
import SDWebImage

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.hasFilters.value {
            scrollToTop()
            removeFooterSpinner()
        }
    }
    
    func scrollToTop() {
        DispatchQueue.main.async {
            self.tableView.setContentOffset(.zero, animated: true)
        }
    }
    
    private func removeFooterSpinner() {
        DispatchQueue.main.async {
            self.tableView.tableFooterView = nil
        }
    }
    
    private func setup() {
        setupLayout()
        setupNavBar()
        showHUD()
        setupObservers()
        bindUI()
    }
    
    private func getData() {
        viewModel.getData()
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(self.view)
        }
    }
    
    private func setupNavBar() {
        navigationItem.title = "Drinks"
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
        let filtersVC = FiltersViewController(viewModel: viewModel)
        navigationController?.pushViewController(filtersVC, animated: true)
    }
    
    func showAlert(hideAfret: Int) {
        let alertController = UIAlertController(title: "No More Cocktails!", message: "", preferredStyle: .alert)
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(hideAfret)) {
            alertController.dismiss(animated: true)
        }
    }
    
    private func setupObservers() {
        
        viewModel.noMoreCocktails
            .subscribe(onNext: { noMore in
                if noMore {
                    self.removeFooterSpinner()
                    self.showAlert(hideAfret: 2)
                }
            })
            .disposed(by: bag)
        
        viewModel.isLoadedData
            .subscribe(onNext: { isLoaded in
                if isLoaded {
                    DispatchQueue.main.async {
                        self.hideHUD()
                        self.footerSpinner.stopAnimating()
                    }
                }
            })
            .disposed(by: bag)
        
        viewModel.hasFilters
            .subscribe(onNext: { hasFilters in
                self.setupFiltersBarButton(showBadge: hasFilters)
            })
            .disposed(by: bag)
    }
    
    private func bindUI() {
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<Category, Cocktail>> { (dataSource, table, indexPath, cocktail) in
            let cell = self.tableView.dequeueReusableCell(withIdentifier: CocktailCell.reuseID, for: indexPath) as! CocktailCell
            cell.cocktailImageView.sd_setImage(with: URL(string: cocktail.thumbLink ?? ""), placeholderImage: UIImage(named: "placeholder"))
            cell.cocktailLabel.text = cocktail.name
            cell.separatorInset.left = Constants.defaultPadding * 2
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
                if indexPath == self.tableView.lastIndexPath(),
                   self.viewModel.isLoadedData.value,
                   !self.viewModel.hasFilters.value,
                   !self.viewModel.noMoreCocktails.value {
                    
                    DispatchQueue.main.async {
                        self.tableView.tableFooterView = self.footerSpinner
                        self.footerSpinner.startAnimating()
                        self.viewModel.getMoreCocktails()
                    }
                }
            })
            .disposed(by: bag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: bag)
    }
}

// MARK: - table view delegate -

extension CocktailsViewController: UITableViewDelegate {
    
    private func setupHeaderView(for section: Int) -> UIView {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: Constants.headerViewHeight))
        headerView.backgroundColor = Constants.headerBgColor
        
        let textLabel = UILabel()
        textLabel.font = Constants.headerTextFont
        textLabel.textColor = Constants.headerTextColor
        textLabel.text = viewModel.sections.value[section].model.name.uppercased()
        
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
        return setupHeaderView(for: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerViewHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.rowHeight
    }
}
