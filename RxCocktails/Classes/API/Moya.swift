//
//  Moya.swift
//  RxCocktails
//
//  Created by Butsan Vitaliy on 15.06.2021.
//

import Moya

enum CocktailsService {
    case getCategories
    case filterCocktails(by: String)
}

// MARK: - TargetType Protocol Implementation

extension CocktailsService: TargetType {
    
    var baseURL: URL {
        URL(string: "https://www.thecocktaildb.com/api/json/v1/1")!
    }
    
    var path: String {
        switch self {
        case .getCategories:
            return "/list.php"
        case .filterCocktails:
            return "/filter.php"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getCategories, .filterCocktails:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getCategories:
            return .requestParameters(parameters: ["c" : "list"], encoding: URLEncoding.default)
        case .filterCocktails(let category):
            return .requestParameters(parameters: ["c" : "\(category)"], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
