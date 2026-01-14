//
//  ViewState.swift
//  MovieProjectSwiftUI
//
//  Created by Çağatay Eğilmez on 14.01.2026.
//

enum ViewState: Equatable {

    case loading
    case empty
    case success
    case error(message: String)
}
