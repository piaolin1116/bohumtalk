//
//  WKWebViewWrapper.swift
//  BohumTalk
//
//  Created by 조유진 on 3/10/25.
//

import UIKit
import WebKit
import Combine

final class WKWebViewWrapper: NSObject {
    let webView: WKWebView
    private let navigationDelegate = NavigationDelegateHandler()
    private let scriptMessageHandler: ScriptMessageHandlerWrapper
    
    init(messageHandlerNames: [String] = []) {
        self.scriptMessageHandler = ScriptMessageHandlerWrapper(names: messageHandlerNames)

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = scriptMessageHandler.userContentController

        webView = WKWebView(frame: .zero, configuration: configuration)
        super.init()
        webView.navigationDelegate = navigationDelegate
        configureWebView()
    }
    
    deinit {
        scriptMessageHandler.userContentController.removeAllScriptMessageHandlers()
        scriptMessageHandler.removeAllMessageHandlers()
    }
    
    // Publishers
    var didFinishPublisher: AnyPublisher<WKNavigation, Never> {
        navigationDelegate.didFinishNavigation.eraseToAnyPublisher()
    }

    var didFailPublisher: AnyPublisher<(WKNavigation?, Error), Never> {
        navigationDelegate.didFailNavigation.eraseToAnyPublisher()
    }
    
    var didStartProvisionalPublisher: AnyPublisher<WKNavigation, Never> {
        navigationDelegate.didStartProvisionalNavigation.eraseToAnyPublisher()
    }
    
    var didReceiveServerRedirectForProvisionalPublisher: AnyPublisher<WKNavigation, Never> {
        navigationDelegate.didReceiveServerRedirectForProvisionalNavigation.eraseToAnyPublisher()
    }
    
    var didCommitPublisher: AnyPublisher<WKNavigation, Never> {
        navigationDelegate.didCommitNavigation.eraseToAnyPublisher()
    }
    
    var didFailProvisionalPublisher: AnyPublisher<(WKNavigation?, Error), Never> {
        navigationDelegate.didFailProvisionalNavigation.eraseToAnyPublisher()
    }
    
    var decidePolicyForNavigationActionPublisher: AnyPublisher<(WKNavigationAction, (WKNavigationActionPolicy) -> Void), Never> {
        navigationDelegate.decidePolicyForNavigationAction.eraseToAnyPublisher()
    }
    
    var decidePolicyForNavigationResponsePublisher: AnyPublisher<(WKNavigationResponse, (WKNavigationResponsePolicy) -> Void), Never> {
        navigationDelegate.decidePolicyForNavigationResponse.eraseToAnyPublisher()
    }
    
    var webContentProcessDidTerminate: AnyPublisher<WKWebView, Never> {
        navigationDelegate.webContentProcessDidTerminate.eraseToAnyPublisher()
    }
    
    var didReceiveMessage: AnyPublisher<WKScriptMessage, Never> {
        scriptMessageHandler.didReceive.eraseToAnyPublisher()
    }
    
    func sendMessageToWeb(_ script: String) -> AnyPublisher<Any?, Error> {
         webView.evaluateJavaScriptPublisher(script: script)
             .eraseToAnyPublisher()
     }
}

extension WKWebViewWrapper {
    func configureWebView() {
        webView.backgroundColor = .white
        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.alwaysBounceVertical = false
        webView.scrollView.keyboardDismissMode = .onDrag
        webView.allowsLinkPreview = false
    }
    
    func loadURL(_ url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func reloadURL() {
        guard let url = webView.url else {
            guard let homeUrlString = Bundle.main.infoDictionary?["HOME_URL"] as? String else {
                fatalError("HOME_URL not found in Info.plist")
            }
            webView.load(URLRequest(url: URL(string: homeUrlString)!))
            return
        }
        
        webView.load(URLRequest(url: url))
    }
}
