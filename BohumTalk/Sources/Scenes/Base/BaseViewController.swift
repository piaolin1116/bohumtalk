//
//  BaseViewController.swift
//  BohumTalk
//
//  Created by 조유진 on 3/10/25.
//

import UIKit
import Combine

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    func bind() { }
    
    func showAlert(title: String? = nil, message: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: handler))
        present(alert, animated: true)
    }
}
