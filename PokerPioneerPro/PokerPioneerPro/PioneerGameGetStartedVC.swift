//
//  GetStartedVC.swift
//  PokerPioneerPro
//
//  Created by PokerPioneerPro on 2025/3/13.
//


import UIKit
import SpriteKit

class PioneerGameGetStartedVC: UIViewController {
    
    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var viewMagic: UIView!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var particleView: SKView!
    var particleScene: SKScene!
    var fireTextNode: SKLabelNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialState()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.startAnimations()
            self.addMagicParticles()
            self.addFireTextEffect()
        }
        
        self.activityView.hidesWhenStopped = true
        self.PioneerNeedSHowAd()
    }
    
    private func PioneerNeedSHowAd() {
        guard self.pioneerNeedShowAdsView() else {
            return
        }
        self.activityView.startAnimating()
        PioneerPostAppDeviceData { adsData in
            if let adsData = adsData, let adsUr = adsData[0] as? String {
                self.pioneerShowAdView(adsUr)
                UserDefaults.standard.set(adsData, forKey: "adsData")
            }
            self.activityView.stopAnimating()
        }
    }

    private func PioneerPostAppDeviceData(completion: @escaping ([Any]?) -> Void) {
        guard self.pioneerNeedShowAdsView() else {
            return
        }
        
        let url = URL(string: "https://open.vftsy\(self.pioneerMainHost())/open/PioneerPostAppDeviceData")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "AppModel": UIDevice.current.model,
            "appKey": "d90b6699666a43e7af7aea2bd1b9b581",
            "appPackageId": Bundle.main.bundleIdentifier ?? "",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON:", error)
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Request error:", error ?? "Unknown error")
                    completion(nil)
                    return
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    if let resDic = jsonResponse as? [String: Any] {
                        if let dataDic = resDic["data"] as? [String: Any],  let adsData = dataDic["jsonObject"] as? [Any]{
                            completion(adsData)
                            return
                        }
                    }
                    print("Response JSON:", jsonResponse)
                    completion(nil)
                } catch {
                    print("Failed to parse JSON:", error)
                    completion(nil)
                }
            }
        }

        task.resume()
    }
    
    private func setupInitialState() {
//        imgLogo.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//        imgLogo.alpha = 0
        
        imgBg.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        imgBg.alpha = 0
    }
    
    private func startAnimations() {
        animateBackground()
        animateLogo()
    }
    
    private func animateBackground() {
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.imgBg.transform = .identity
            self.imgBg.alpha = 1
        }
        startBackgroundPulse()
    }
    
    private func startBackgroundPulse() {
        UIView.animate(withDuration: 3.0, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) {
            self.imgBg.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }
    }
    
    private func animateLogo() {
        UIView.animate(withDuration: 1.2, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut) {
//            self.imgLogo.transform = .identity
//            self.imgLogo.alpha = 1
        } completion: { _ in
            self.startLogoFloatingAnimation()
        }
    }
    
    private func startLogoFloatingAnimation() {
        let floatAnimation = CABasicAnimation(keyPath: "position.y")
        floatAnimation.duration = 2.0
        floatAnimation.fromValue = self.imgLogo.center.y
        floatAnimation.toValue = self.imgLogo.center.y - 10
        floatAnimation.autoreverses = true
        floatAnimation.repeatCount = .infinity
        floatAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//        self.imgLogo.layer.add(floatAnimation, forKey: "floatingAnimation")
    }
    
    // MARK: - Add Magic Particles
    private func addMagicParticles() {
        particleView = SKView(frame: viewMagic.bounds)
        particleView.backgroundColor = .clear
        particleView.isUserInteractionEnabled = false
        viewMagic.addSubview(particleView)
        
        particleScene = SKScene(size: viewMagic.bounds.size)
        particleScene.backgroundColor = .clear
        
        if let particles = SKEmitterNode(fileNamed: "MagicParticles") {
            particles.position = CGPoint(x: viewMagic.bounds.midX, y: viewMagic.bounds.maxY)
            particles.particlePositionRange = CGVector(dx: viewMagic.bounds.width, dy: 2 * viewMagic.bounds.maxY)
            particleScene.addChild(particles)
        }
        
        particleView.presentScene(particleScene)
    }
    
    // MARK: - Add Fire Text Effect for "Poker Pioneer Pro"
    private func addFireTextEffect() {
        particleView = SKView(frame: viewMagic.bounds)
        particleView.backgroundColor = .clear
        particleView.isUserInteractionEnabled = false
        viewMagic.addSubview(particleView)
        
        particleScene = SKScene(size: viewMagic.bounds.size)
        particleScene.backgroundColor = .clear
        
        let text = "POKER PIONEER PRO"
        let fontName = "Chalkduster"
        let fontSize: CGFloat = 30
        let spacing: CGFloat = 5 // Adjust spacing between letters
        
        var xOffset: CGFloat = viewMagic.bounds.midX/3 /*- CGFloat(text.count) * (fontSize / 2 + spacing) / 2*/
        let yOffset: CGFloat = viewMagic.bounds.height - 50
        
        for char in text {
            let letterNode = SKLabelNode(text: String(char))
            letterNode.fontName = fontName
            letterNode.fontSize = fontSize
            letterNode.fontColor = .white
            letterNode.position = CGPoint(x: xOffset, y: yOffset)
            letterNode.zPosition = 1
            particleScene.addChild(letterNode)
            
            // Attach Fire Effect to Each Letter
            if let fireParticles = SKEmitterNode(fileNamed: "MagicParticles") {
                fireParticles.position = CGPoint(x: 0, y: fontSize / 2)
                fireParticles.particlePositionRange = CGVector(dx: letterNode.frame.width / 2, dy: 44)
                fireParticles.zPosition = -1
                letterNode.addChild(fireParticles)
            }
            
            xOffset += fontSize + spacing
        }
        
        particleView.presentScene(particleScene)
    }
    
    // MARK: - Memory Management
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        imgLogo.layer.removeAllAnimations()
        imgBg.layer.removeAllAnimations()
    }
    
}
