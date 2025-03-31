//
//  NetworkConnectionErrorView.swift
//  BohumTalk
//
//  Created by 조유진 on 3/10/25.
//

import UIKit
import SnapKit

final class NetworkConnectionErrorView: BaseView {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override func configureHierarchy() {
        [imageView, titleLabel, descriptionLabel].forEach {
            addSubview($0)
        }
    }
    
    override func configureLayout() {
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(23)
        }
        
        imageView.snp.makeConstraints { make in
            make.bottom.equalTo(titleLabel.snp.top).offset(-14)
            make.centerX.equalToSuperview()
            make.size.equalTo(126)
        }
    }
    
    override func configureView() {
        backgroundColor = .white.withAlphaComponent(0.98)
        imageView.image = .cloudOff
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.design(text: "앗! 오프라인 상태인 것 같아요", textColor: .black, font: .pretendard(size: 18, weight: .semiBold), textAlignment: .center)
        descriptionLabel.design(text: "보험톡을 이용하려면 인터넷 연결이 필요해요.\nWi-Fi 혹은 데이터 네트워크를 연결해주세요.", textColor: .gray, font: .pretendard(size: 16, weight: .regular), textAlignment: .center, numberOfLines: 3)
        descriptionLabel.setLineSpacing(spacing: 10)
        descriptionLabel.textAlignment = .center
    }
}
