//
//  HomeVC.swift
//  PokerPioneerPro
//
//  Created by PokerPioneerPro on 2025/3/13.
//


import UIKit
import StoreKit
import SpriteKit

class PioneerGameHomeVC: UIViewController {

    @IBOutlet var bvAdd: UIVisualEffectView!
    @IBOutlet weak var viewMagic: UIView!
    @IBOutlet weak var btnRate: UIButton!
    @IBOutlet weak var lblScore: UILabel!
    
    var particleView: SKView!
    var particleScene: SKScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnRate.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/20)
        setupParticles()
        addFireTextEffect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lblScore.text = "\(score) ✿"
    }
    
    @IBAction func btnAdd(_ sender: UIButton) {
        if sender.tag == 1 {
            // Fade out and remove
            UIView.animate(withDuration: 0.3, animations: {
                self.bvAdd.alpha = 0
                self.bvAdd.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            }) { _ in
                self.bvAdd.removeFromSuperview()
                // Reset for next time
                self.bvAdd.alpha = 1
                self.bvAdd.transform = .identity
            }
        } else {
            // Setup initial state
            let size = UIScreen.main.bounds.size
            bvAdd.frame.size = size
            bvAdd.center = CGPoint(x: size.width/2, y: size.height/2)
            bvAdd.alpha = 0
            bvAdd.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            view.addSubview(bvAdd)
            
            // Animate in
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                self.bvAdd.alpha = 1
                self.bvAdd.transform = .identity
            }
        }
    }
    
    private func setupParticles() {
        // Create SKView with viewMagic bounds
        let skView = SKView()
        skView.frame.size = CGSize(width: 900, height: 600)
        skView.allowsTransparency = true
        skView.backgroundColor = .clear
        
        let scene = SKScene()
        scene.size = viewMagic.bounds.size
        scene.backgroundColor = .clear
        if let particles = SKEmitterNode(fileNamed: "MagicParticles") {
            particles.position = CGPoint(x: viewMagic.bounds.midX/2, y: viewMagic.bounds.maxY/2)
            scene.addChild(particles)
        }
        
        skView.presentScene(scene)
        viewMagic.insertSubview(skView, at: 0) // Add behind other content
    }
    
    private func addFireTextEffect() {
        particleView = SKView()
        particleView.frame.size = CGSize(width: 800, height: 600)
        particleView.backgroundColor = .clear
        particleView.isUserInteractionEnabled = false
        viewMagic.addSubview(particleView)
        
        particleScene = SKScene(size: viewMagic.bounds.size)
        particleScene.backgroundColor = .clear
        
        let text = "POKER PIONEER PRO"
        let fontName = "Chalkduster"
        let fontSize: CGFloat = 14
        let spacing: CGFloat = 3 // Adjust spacing between letters
        
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
                fireParticles.particleBirthRate = 5
                fireParticles.particleLifetime = 2
                fireParticles.speed = 0.001
                fireParticles.particleScale = 0.001
                fireParticles.position = CGPoint(x: 0, y: fontSize / 2)
                fireParticles.particlePositionRange = CGVector(dx: letterNode.frame.width / 2, dy: 0)
                fireParticles.zPosition = -1
                letterNode.addChild(fireParticles)
            }
            
            xOffset += fontSize + spacing
        }
        
        particleView.presentScene(particleScene)
    }
    
    @IBAction func btnAbout(_ sender: UIButton) {
        
        bvAdd.removeFromSuperview()
        
        let alert = UIAlertController(
            title: "Poker Pioneer Pro",
            message: """
            YOU HAVE TO CLICK SMALLEST/LOW-VALUE POKER CARD TO GET SCORE
            YOU HAVE TO CLICK SMALLEST/LOW-VALUE POKER CARD TO GET SCORE
            YOU HAVE TO CLICK SMALLEST/LOW-VALUE POKER CARD TO GET SCORE
            PRESS OK TO START
            PRESS OK TO START
            """,
            preferredStyle: .alert
        )
        
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.first?.backgroundColor = .darkGray
        let bg = UIImageView(image: UIImage(named: "bg"))
        bg.alpha = 0.3
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.first?.insertSubview(bg,at: 0)
        alert.view.subviews.first?.subviews.first?.subviews.first?.subviews.last?.subviews.first?.backgroundColor = .black
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
    }
    
    @IBAction func btnRate(_ sender: Any) {
        
        SKStoreReviewController.requestReview()
        
        vibrate(.soft)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2){
            self.bvAdd.removeFromSuperview()
        }
    }
    
}
