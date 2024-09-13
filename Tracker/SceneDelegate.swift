//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Артур  Арсланов on 25.06.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "isOnboardingShown")
        
        if hasSeenOnboarding {
            window?.rootViewController = TabBarController()
        } else {
            window?.rootViewController = OnboardingPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        }
        
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }


}

