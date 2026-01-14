//
//  HomeViewModelProtocol.swift
//  MovieProjectSwiftUI
//
//  Created by Çağatay Eğilmez on 14.01.2026.
//

import Foundation
import Combine

protocol HomeViewModelProtocol: ObservableObject {
    
    var state: ViewState { get }
    var nowPlaying: [MovieListModel] { get }
    var upcoming: [MovieListModel] { get }
    var alertMessage: String? { get }
    
    func onAppear()
    func loadInitial() async
    func refresh() async
    func loadMore() async
    func didSelectNowPlaying(movieId: Int)
    func didSelectUpcoming(movie: MovieListModel)
}
