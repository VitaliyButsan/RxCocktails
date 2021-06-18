//
//  CocktailCell.swift
//  RxCocktails
//
//  Created by Butsan Vitaliy on 17.06.2021.
//

import UIKit
import SnapKit
import SDWebImage

class CocktailCell: UITableViewCell {
    
    static let reuseID = "CocktailCell"
    
    let cocktailLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.cocktailCellFont
        return label
    }()
    
    let cocktailImageView: UIImageView = {
        let imageView = UIImageView()
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
        [cocktailLabel,
         cocktailImageView].forEach { contentView.addSubview($0) }
        
        cocktailImageView.snp.makeConstraints { make in
            make.leading.equalTo(contentView.snp.leading).inset(Constants.defaultPadding * 2)
            make.height.equalTo(60)
            make.width.equalTo(60)
            make.centerY.equalToSuperview()
        }
        
        cocktailLabel.snp.makeConstraints { make in
            make.top.bottom.trailing.equalTo(contentView)
            make.leading.equalTo(cocktailImageView.snp.trailing).inset(-20)
        }
    }
    
    func setupCell(with cocktail: Cocktail) {
        cocktailImageView.sd_setImage(with: URL(string: cocktail.thumbLink ?? ""), placeholderImage: UIImage(named: "placeholder"))
        cocktailLabel.text = cocktail.name
        separatorInset.left = Constants.defaultPadding * 2
    }
}
