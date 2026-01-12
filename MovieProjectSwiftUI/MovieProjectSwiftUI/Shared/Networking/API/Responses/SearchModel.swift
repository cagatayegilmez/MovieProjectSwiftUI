//
//  SearchModel.swift
//  Mobillium Project
//
//  Created by Çağatay Eğilmez on 15.05.2022.
//

import Foundation
struct SearchModel: Decodable {
    let page: Int
    let total_pages: Int
    let results: [MovieListModel]
}
