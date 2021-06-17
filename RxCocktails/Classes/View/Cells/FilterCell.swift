//
//  FilterCell.swift
//  RxCocktails
//
//  Created by Butsan Vitaliy on 16.06.2021.
//

import UIKit
import SnapKit

class FilterCell: UITableViewCell {
    
    static let reuseID = "FilterCell"
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.cocktailCellFont
        return label
    }()
    
    let checkmark: UIImageView = {
        let icon = UIImage(named: "checkmark")
        let imageView = UIImageView(image: icon)
        imageView.isHidden = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setupLayout()
    }
    
    private func setupLayout() {
        [categoryLabel,
         checkmark].forEach { contentView.addSubview($0) }
        
        categoryLabel.snp.makeConstraints { make in
            make.top.bottom.trailing.equalTo(contentView)
            make.leading.equalTo(20)
            make.height.equalTo(50)
        }
        
        checkmark.snp.makeConstraints { make in
            make.trailing.equalTo(contentView.snp.trailing).inset(16)
            make.height.equalTo(30)
            make.width.equalTo(30)
            make.centerY.equalToSuperview()
        }
    }
}
