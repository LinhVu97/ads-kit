//
//  GradientButton.swift
//  FidraCore
//
//  Created by HoaTD on 28/2/25.
//

import UIKit

class GradientNativeAdButton: UIButton {

    var colors: [CGColor] = [UIColor.white.cgColor] {
        didSet {
            if colors.count == 1 {
                let colorInput = colors + colors
                gradientLayer.colors = colorInput
            } else {
                gradientLayer.colors = colors
            }
            
            setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    private lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds
        l.colors = colors
        l.startPoint = CGPoint(x: 0, y: 0.5)
        l.endPoint = CGPoint(x: 1, y: 0.5)
        l.cornerRadius = layer.cornerRadius
        if colors.count > 1 {
            l.locations = (0..<colors.count).map {
                NSNumber(value: Float($0) / Float(colors.count - 1))
            }
        }
        layer.insertSublayer(l, at: 0)
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        layer.masksToBounds = true
        _ = gradientLayer // Ensure gradient layer is created
    }
    
    public func applyRadialStyle(colors: [CGColor], cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        gradientLayer.type = .radial
        gradientLayer.colors = colors
        gradientLayer.locations = [0.0, 0.6, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.04)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.transform = CATransform3DMakeRotation(.pi, 1, 0, 0)
        if gradientLayer.superlayer == nil {
            layer.insertSublayer(gradientLayer, at: 0)
        }
    }
}
