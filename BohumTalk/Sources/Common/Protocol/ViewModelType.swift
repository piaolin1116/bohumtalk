//
//  ViewModelType.swift
//  BohumTalk
//
//  Created by 조유진 on 3/10/25.
//

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
  
    func transform(input: Input) -> Output
}
