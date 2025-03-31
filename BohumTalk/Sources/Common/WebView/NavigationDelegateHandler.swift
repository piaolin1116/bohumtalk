//
//  NavigationDelegateHandler.swift
//  BohumTalk
//
//  Created by 조유진 on 3/10/25.
//

@preconcurrency import WebKit
import Combine

final class NavigationDelegateHandler: NSObject, WKNavigationDelegate {

    // MARK: - Publishers 정의
    let didStartProvisionalNavigation = PassthroughSubject<WKNavigation, Never>()
    let didReceiveServerRedirectForProvisionalNavigation = PassthroughSubject<WKNavigation, Never>()
    let didCommitNavigation = PassthroughSubject<WKNavigation, Never>()
    let didFinishNavigation = PassthroughSubject<WKNavigation, Never>()
    let didFailNavigation = PassthroughSubject<(WKNavigation?, Error), Never>()
    let didFailProvisionalNavigation = PassthroughSubject<(WKNavigation?, Error), Never>()
    let decidePolicyForNavigationAction = PassthroughSubject<(WKNavigationAction, (WKNavigationActionPolicy) -> Void), Never>()
    let decidePolicyForNavigationResponse = PassthroughSubject<(WKNavigationResponse, (WKNavigationResponsePolicy) -> Void), Never>()
    let webContentProcessDidTerminate = PassthroughSubject<WKWebView, Never>()

    // MARK: - WKNavigationDelegate 메서드 구현
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        didStartProvisionalNavigation.send(navigation)
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        didReceiveServerRedirectForProvisionalNavigation.send(navigation)
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        didCommitNavigation.send(navigation)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        didFinishNavigation.send(navigation)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        didFailNavigation.send((navigation, error))
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        didFailNavigation.send((navigation, error))
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decidePolicyForNavigationAction.send((navigationAction, decisionHandler))
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decidePolicyForNavigationResponse.send((navigationResponse, decisionHandler))
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webContentProcessDidTerminate.send(webView)
    }
}
