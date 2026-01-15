//
//  SceneDelegate.swift
//  MovieProjectSwiftUI
//
//  Created by Çağatay Eğilmez on 15.01.2026.
//

import UIKit
import SwiftUI

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let coordinator = AppCoordinator()
        let rootView = AppCoordinatorRootView(coordinator: coordinator)
        let hosting = UIHostingController(rootView: rootView)
        hosting.view.backgroundColor = .systemBackground
        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .systemBackground
        let rootVC = UIViewController()
        rootVC.view.backgroundColor = .systemBackground
        window.rootViewController = rootVC
        window.makeKeyAndVisible()

        rootVC.addChild(hosting)
        rootVC.view.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: rootVC.view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: rootVC.view.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: rootVC.view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: rootVC.view.bottomAnchor),
        ])
        hosting.didMove(toParent: rootVC)

        self.window = window
    }
}
