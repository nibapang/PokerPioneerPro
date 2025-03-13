//
//  UIViewController+Back.swift
//  PokerPioneerPro
//
//  Created by PokerPioneerPro on 2025/3/13.
//


import UIKit

extension UIViewController{
    
    @IBAction func btnBack(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    func vibrate(_ type: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: type)
        generator.prepare()
        generator.impactOccurred()
    }
    
}
