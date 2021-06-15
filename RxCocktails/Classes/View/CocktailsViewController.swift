//
//  ViewController.swift
//  RxCocktails
//
//  Created by Butsan Vitaliy on 15.06.2021.
//

import UIKit

class CocktailsViewController: UIViewController {

    let viewModel = CocktailsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        
        viewModel.getData()
        // Do any additional setup after loading the view.
    }
}
