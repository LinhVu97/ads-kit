import UIKit
import GoogleMobileAds
import SwiftUI

extension Color {
    func toUIColor() -> UIColor {
        if #available(iOS 14.0, *) {
            return UIColor(self)
        } else {
            let components = self.components()
            return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
        }
    }
    
    private func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 1
        
        if scanner.scanHexInt64(&hexNumber) {
            r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
            g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
            b = CGFloat(hexNumber & 0x0000ff) / 255
        }
        return (r, g, b, a)
    }
}

protocol NativeAdLayoutBuilder {
    func setupLayout(nativeAdView: NativeAdView, nativeAd: NativeAd, configuration: NativeAdConfiguration)
    func setupComponents(nativeAdView: NativeAdView, configuration: NativeAdConfiguration)
    func setupMediaView(nativeAdView: NativeAdView)
    func setupTextAd(nativeAdView: NativeAdView, configuration: NativeAdConfiguration)->UILabel
}

extension NativeAdLayoutBuilder {
    func setupComponents(nativeAdView: NativeAdView, configuration: NativeAdConfiguration) {
        // Headline
        let headlineLabel = UILabel()
        headlineLabel.numberOfLines = configuration.headlineStyle.numberOfLines
        headlineLabel.font = configuration.headlineStyle.font
        headlineLabel.textColor = configuration.headlineStyle.textColor.toUIColor()
        headlineLabel.isUserInteractionEnabled = false
        headlineLabel.textAlignment = configuration.headlineStyle.textAlignment
        nativeAdView.headlineView = headlineLabel
        
        // Body
        let bodyLabel = UILabel()
        bodyLabel.numberOfLines = configuration.bodyStyle.numberOfLines
        bodyLabel.font = configuration.bodyStyle.font
        bodyLabel.textColor = configuration.bodyStyle.textColor.toUIColor()
        bodyLabel.textAlignment = configuration.bodyStyle.textAlignment
        bodyLabel.isUserInteractionEnabled = false
        nativeAdView.bodyView = bodyLabel
     
        // Icon
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true
        iconImageView.isUserInteractionEnabled = false
        nativeAdView.iconView = iconImageView
        
        // Call to action button
        let callToActionButton = GradientNativeAdButton()
        callToActionButton.titleLabel?.font = configuration.callActionStyle.font
        callToActionButton.titleLabel?.textColor = configuration.callActionStyle.textColor.toUIColor()
        callToActionButton.layer.cornerRadius = configuration.callActionStyle.cornerRadius
        callToActionButton.colors = configuration.callActionStyle.backgroundColor
        callToActionButton.layer.borderColor = configuration.callActionStyle.borderColor.toUIColor().cgColor
        callToActionButton.layer.borderWidth = configuration.callActionStyle.borderWidth
        callToActionButton.isUserInteractionEnabled = false
        nativeAdView.callToActionView = callToActionButton
       
        // Add subviews
        nativeAdView.addSubview(headlineLabel)
        nativeAdView.addSubview(bodyLabel)
        nativeAdView.addSubview(iconImageView)
        nativeAdView.addSubview(callToActionButton)
        nativeAdView.isUserInteractionEnabled = true
        
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        callToActionButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupMediaView(nativeAdView: NativeAdView) {
        let mediaView = MediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.mediaView = mediaView
        nativeAdView.addSubview(mediaView)
    }

    func setupTextAd(nativeAdView: NativeAdView, configuration: NativeAdConfiguration) -> UILabel {
        let textAdView = UILabel()
        textAdView.text = configuration.adBadgeStyle.text
        textAdView.font = configuration.adBadgeStyle.font
        textAdView.textColor = configuration.adBadgeStyle.textColor.toUIColor()
        textAdView.backgroundColor = configuration.adBadgeStyle.backgroundColor.toUIColor()
        textAdView.layer.cornerRadius = configuration.adBadgeStyle.cornerRadius
        textAdView.clipsToBounds = true
        textAdView.isUserInteractionEnabled = false
        textAdView.textAlignment = .center
        textAdView.layoutMargins = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        nativeAdView.addSubview(textAdView)
        
        textAdView.translatesAutoresizingMaskIntoConstraints = false
        var constraints: [NSLayoutConstraint] = [
            textAdView.widthAnchor.constraint(greaterThanOrEqualToConstant: Utils.dp(16)),
            textAdView.heightAnchor.constraint(equalToConstant: Utils.dp(16))
        ]
        switch configuration.adBadgeStyle.position {
        case .topLeft:
            constraints.append(textAdView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: configuration.adBadgeStyle.margin.top + 4))
            constraints.append(textAdView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: configuration.adBadgeStyle.margin.leading + 4))
        default:
            constraints.append(textAdView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: configuration.adBadgeStyle.margin.top + 6))
            constraints.append(textAdView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: configuration.adBadgeStyle.margin.trailing - 4))
        }
        NSLayoutConstraint.activate(constraints)
        return textAdView
    }
}



