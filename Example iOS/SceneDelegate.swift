//
//  SceneDelegate.swift
//  Example iOS
//
//  Created by Eugene Dudnyk on 15/07/2019.
//  Copyright © 2019 Imaginarium Works. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}

