//
//  PioneerGamePolicyController.swift
//  PokerPioneerPro
//
//  Created by PokerPioneerPro on 2025/3/13.
//

import UIKit
import WebKit

class PioneerGamePolicyController: UIViewController , WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate{

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var webView: WKWebView!
    @objc var url: String?
    let pioneerPrivacyDefaultUrl = "https://www.termsfeed.com/live/8d082630-de1e-4d51-8701-1190072c6696"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        chaseRakeInitSubViews()
        chaseRakeInitWebView()
        cardessyStartLoadWebView()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscape]
    }
    
    private func chaseRakeInitSubViews() {
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = .black
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .black
        indicatorView.hidesWhenStopped = true
        
        self.backBtn.isHidden = self.url != nil
    }

    private func chaseRakeInitWebView() {
        let userContentC = webView.configuration.userContentController
        
        // afevent
        userContentC.add(self, name: "trackWebEventToAF")
        webView.navigationDelegate = self
        webView.uiDelegate = self
    }
    
    private func cardessyStartLoadWebView() {
        let urlStr = url ?? pioneerPrivacyDefaultUrl
        guard let url = URL(string: urlStr) else { return }
        
        indicatorView.startAnimating()
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "trackWebEventToAF" {
            if let dic = message.body as? [String: Any], let event = dic["event"] as? String {
                let da = UserDefaults.standard.value(forKey: "adsData") as? [String] ?? Array()
                if event == da[7], let ur = dic["data"] as? String, let url = URL(string: ur) {
                    UIApplication.shared.open(url)
                } else {
                    pioneerLogEvent(event, data: dic["data"] as? [String: Any] ?? Dictionary())
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.indicatorView.stopAnimating()
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
            self.indicatorView.stopAnimating()
        }
    }
    
    // MARK: - WKUIDelegate
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            UIApplication.shared.open(url)
        }
        return nil
    }

}
