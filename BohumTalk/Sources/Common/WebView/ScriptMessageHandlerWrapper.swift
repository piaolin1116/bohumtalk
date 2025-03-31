//
//  ScriptMessageHandlerWrapper.swift
//  BohumTalk
//
//  Created by 조유진 on 3/10/25.
//

import WebKit
import Combine

final class ScriptMessageHandlerWrapper: NSObject, WKScriptMessageHandler {
    let userContentController = WKUserContentController()
    let didReceive = PassthroughSubject<WKScriptMessage, Never>()

    init(names: [String]) {
        super.init()
        names.forEach { name in
            addMessageHandler(name: name)
        }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        didReceive.send(message)
    }

    deinit {
        removeAllMessageHandlers()
    }
    
    func removeAllMessageHandlers() {
        userContentController.removeAllScriptMessageHandlers()
    }
    
    private func addMessageHandler(name: String) {
         userContentController.add(self, name: name)
    }
}
