//
//  BaseView.swift
//  BohumTalk
//
//  Created by 조유진 on 3/10/25.
//

import UIKit
import SnapKit

class BaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHierarchy() { }

    func configureLayout() { }
    
    func configureView() {
        backgroundColor = .white
    }
}
