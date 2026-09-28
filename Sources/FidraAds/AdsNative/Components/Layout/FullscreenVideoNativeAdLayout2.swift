import GoogleMobileAds
import UIKit
import SwiftUI

class FullscreenVideoNativeAdLayout2: NativeAdLayoutBuilder {
    func setupLayout(nativeAdView: NativeAdView, nativeAd: NativeAd, configuration: NativeAdConfiguration) {
        setupMediaView(nativeAdView: nativeAdView)
        setupComponents(nativeAdView: nativeAdView, configuration: configuration)
        let textAds = setupTextAd(nativeAdView: nativeAdView, configuration: configuration)
        textAds.removeFromSuperview()
        
        nativeAdView.backgroundColor = .clear
        nativeAdView.clipsToBounds = true
        
        if let mediaView = nativeAdView.mediaView {
            mediaView.layer.cornerRadius = 0
            mediaView.clipsToBounds = true
            mediaView.contentMode = .scaleAspectFill
            mediaView.mediaContent = nativeAd.mediaContent
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                mediaView.topAnchor.constraint(equalTo: nativeAdView.topAnchor),
                mediaView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor),
                mediaView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
                mediaView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor)
            ])
        }
        
        let infoView = UIView()
        infoView.backgroundColor = UIColor.clear
        nativeAdView.addSubview(infoView)
        
        let horizontalPadding = Utils.dp(9)
        let verticalPaddingTop = Utils.dp(9)
        let verticalPaddingBottom = Utils.dp(9)
        let spacing = Utils.dp(8)
        
        infoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(16)),
            infoView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-16)),
            infoView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: Utils.dp(-20)),
            infoView.heightAnchor.constraint(equalToConstant: Utils.dp(123))
        ])
        
        let iconView = nativeAdView.iconView as? UIImageView
        let headlineView = nativeAdView.headlineView as? UILabel
        let bodyView = nativeAdView.bodyView as? UILabel
        let callToActionView = nativeAdView.callToActionView as? GradientNativeAdButton
        
        if let iconView {
            iconView.removeFromSuperview()
            infoView.addSubview(iconView)
        }
        if let headlineView {
            headlineView.removeFromSuperview()
            infoView.addSubview(headlineView)
        }
        if let bodyView {
            bodyView.removeFromSuperview()
            infoView.addSubview(bodyView)
        }
        if let callToActionView {
            callToActionView.removeFromSuperview()
            infoView.addSubview(callToActionView)
        }
        
        if let iconView {
            iconView.backgroundColor = .white
            iconView.image = nativeAd.icon?.image
            iconView.layer.cornerRadius = Utils.dp(8)
            iconView.clipsToBounds = true
            iconView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconView.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: horizontalPadding),
                iconView.topAnchor.constraint(equalTo: infoView.topAnchor, constant: verticalPaddingTop),
                iconView.widthAnchor.constraint(equalToConstant: configuration.iconSize.width),
                iconView.heightAnchor.constraint(equalToConstant: configuration.iconSize.width),
                iconView.bottomAnchor.constraint(lessThanOrEqualTo: infoView.bottomAnchor, constant: -verticalPaddingBottom)
            ])
        }
        
        if let headlineView, let bodyView, let iconView, let callToActionView {
            headlineView.text = nativeAd.headline
            headlineView.font = configuration.headlineStyle.font
            headlineView.numberOfLines = configuration.headlineStyle.numberOfLines
            
            bodyView.text = nativeAd.body
            bodyView.font = configuration.bodyStyle.font
            bodyView.textColor = configuration.bodyStyle.textColor.toUIColor()
            bodyView.numberOfLines = configuration.bodyStyle.numberOfLines
            
            headlineView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headlineView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: spacing),
                headlineView.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -horizontalPadding),
                headlineView.topAnchor.constraint(equalTo: iconView.topAnchor)
            ])
            
            bodyView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bodyView.leadingAnchor.constraint(equalTo: headlineView.leadingAnchor),
                bodyView.trailingAnchor.constraint(equalTo: headlineView.trailingAnchor),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 0),
                bodyView.bottomAnchor.constraint(lessThanOrEqualTo: infoView.bottomAnchor, constant: -verticalPaddingBottom)
            ])
            
            callToActionView.setTitle(nativeAd.callToAction?.uppercased(), for: .normal)
            callToActionView.titleLabel?.font = configuration.callActionStyle.font
            callToActionView.titleLabel?.textColor = configuration.callActionStyle.textColor.toUIColor()
            callToActionView.colors = configuration.callActionStyle.backgroundColor
            callToActionView.layer.cornerRadius = min(configuration.callActionStyle.cornerRadius, configuration.callActionStyle.height / 2)
            callToActionView.setTitleColor(configuration.callActionStyle.textColor.toUIColor(), for: .normal)
            callToActionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                callToActionView.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: Utils.dp(21)),
                callToActionView.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: horizontalPadding),
                callToActionView.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -horizontalPadding),
                callToActionView.heightAnchor.constraint(equalToConstant: configuration.callActionStyle.height)
            ])
        }
    }
}
