//
//  SplashViewController.swift
//  BohumTalk
//
//  Created by 조유진 on 3/10/25.
//

import UIKit

final class SplashViewController: UIViewController {
    private let mainView = SplashView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.showMainViewController()
        }
    }
    
}
