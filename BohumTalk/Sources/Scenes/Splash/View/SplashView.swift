//
//  SplashView.swift
//  BohumTalk
//
//  Created by 조유진 on 3/10/25.
//

import UIKit

final class SplashView: BaseView {
    private let imageView = UIImageView()
    
    override func configureHierarchy() {
        addSubview(imageView)
    }
    
    override func configureLayout() {
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.width.equalTo(UIScreen.main.bounds.width).multipliedBy(0.4)
        }
    }
    
    override func configureView() {
        super.configureView()
        imageView.image = .insuTalkSplash
        imageView.contentMode = .scaleAspectFit
    }
}
