//
//  UIViewController+Extension.swift
//  BohumTalk
//
//  Created by 조유진 on 3/10/25.
//

import UIKit

extension UIViewController {
    
    func showMainViewController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let sceneDelegate = windowScene.delegate as? SceneDelegate,
        let window = sceneDelegate.window else { return }
        
        let mainViewController = WebViewController(viewModel: WebViewModel(
            userRepository: UserRepository(),
            accessTokenRepository: AccessTokenRepository(),
            alarmRepository: AlarmRepository()
        ))

        window.rootViewController = mainViewController
        UIView.transition(with: window, duration: 0.1, options: [.transitionCrossDissolve], animations: nil, completion: nil)
        
        window.makeKey()
    }
}
