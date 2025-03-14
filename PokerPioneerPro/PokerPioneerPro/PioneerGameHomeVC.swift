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
        
        let text = "Card Shift Match"
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
            title: "Card Shift Match",
            message: """
            Card Shift Match

            Card Shift Match is an engaging puzzle game that tests your pattern recognition and strategic planning abilities. Shift, move, and match cards to complete dynamic sequences before time runs out!

            How to Play
            • Start Game: Tap "Start Game" in the main menu to begin the challenge.
            • Shift Cards: Drag the cards to arrange them into the correct sequence shown on the screen.
            • Beat the Clock: Complete each level's pattern before time runs out to advance to tougher challenges.

            Game Features
            • Dynamic Gameplay: Experience fast-paced challenges that require quick thinking and precise movements.
            • Intuitive Mechanics: Simple controls make it easy to learn, but mastering each level requires skill and strategy.
            • Engaging Puzzles: Each level offers a unique pattern-matching puzzle designed to sharpen your brain power.
            • Stunning Visuals: Enjoy smooth animations and eye-catching effects as you move cards into place.
            • Competitive Scoring: Earn points based on speed and accuracy, challenge yourself for the highest score.

            Accept the challenge, sharpen your logical thinking and have endless fun with Card Shift Match!
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
