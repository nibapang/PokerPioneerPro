//
//  CustomView.swift
//  PokerPioneerPro
//
//  Created by PokerPioneerPro on 2025/3/13.
//


import UIKit

class PioneerGameCustomView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            updateCorners()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var topLeftCorner: Bool = false {
        didSet {
            updateCorners()
        }
    }
    
    @IBInspectable var topRightCorner: Bool = false {
        didSet {
            updateCorners()
        }
    }
    
    @IBInspectable var bottomLeftCorner: Bool = false {
        didSet {
            updateCorners()
        }
    }
    
    @IBInspectable var bottomRightCorner: Bool = false {
        didSet {
            updateCorners()
        }
    }
    
    // MARK: - Apply Rounded Corners
    private func updateCorners() {
        var corners: UIRectCorner = []
        
        if topLeftCorner { corners.insert(.topLeft) }
        if topRightCorner { corners.insert(.topRight) }
        if bottomLeftCorner { corners.insert(.bottomLeft) }
        if bottomRightCorner { corners.insert(.bottomRight) }
        
        if !corners.isEmpty {
            let path = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        } else {
            layer.mask = nil // Remove mask if no corners are selected
        }
    }
    
    // MARK: - Update on Layout Changes
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCorners()
    }
}



