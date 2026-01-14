//
//  BaseCoordinator.swift
//  MovieProjectSwiftUI
//
//  Created by Çağatay Eğilmez on 14.01.2026.
//


/// Base coordinator abstraction for MVVM-C.
///
/// Coordinators own navigation/flow only. They must not own UI state or business data.
protocol BaseCoordinator: AnyObject {
    associatedtype Route

    func start() -> Route
}


