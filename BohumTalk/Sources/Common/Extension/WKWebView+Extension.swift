//
//  WKWebView+Extension.swift
//  BohumTalk
//
//  Created by 조유진 on 3/10/25.
//

import WebKit
import Combine

extension WKWebView {
    func evaluateJavaScriptPublisher(script: String) -> Future<Any?, Error> {
        Future { [weak self] promise in
            guard let self else { return }
            evaluateJavaScript(script, completionHandler: { result, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(result))
                }
            })
        }
    }
}
