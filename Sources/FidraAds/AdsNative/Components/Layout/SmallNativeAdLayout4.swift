import UIKit
import GoogleMobileAds

class SmallNativeAdLayout4: NativeAdLayoutBuilder {
    func setupLayout(nativeAdView: NativeAdView, nativeAd: NativeAd, configuration: NativeAdConfiguration) {
        setupComponents(nativeAdView: nativeAdView, configuration: configuration)
        let textView = setupTextAd(nativeAdView: nativeAdView, configuration: configuration)
        
        let iconView = nativeAdView.iconView as? UIImageView
        let headlineView = nativeAdView.headlineView as? UILabel
        let bodyView = nativeAdView.bodyView as? UILabel
        let callToActionView = nativeAdView.callToActionView as? GradientNativeAdButton
        
        textView.removeFromSuperview()
        nativeAdView.addSubview(textView)
        textView.text = configuration.adBadgeStyle.text
        textView.font = configuration.adBadgeStyle.font
        textView.textColor = configuration.adBadgeStyle.textColor.toUIColor()
        textView.backgroundColor = configuration.adBadgeStyle.backgroundColor.toUIColor()
        textView.clipsToBounds = true
        textView.isUserInteractionEnabled = false
        textView.textAlignment = .center
        textView.layer.cornerRadius = Utils.dp(4)
        textView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.widthAnchor.constraint(greaterThanOrEqualToConstant: Utils.dp(20)),
            textView.heightAnchor.constraint(equalToConstant: Utils.dp(13)),
            textView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
            textView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 2)
        ])
        
        let icUIView = UIView()
        nativeAdView.addSubview(icUIView)
        icUIView.backgroundColor = .gray.withAlphaComponent(0.3)
        icUIView.layer.cornerRadius = 8
        
        icUIView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icUIView.widthAnchor.constraint(equalToConstant: Utils.dp(48)),
            icUIView.heightAnchor.constraint(equalToConstant: Utils.dp(48)),
            icUIView.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: Utils.dp(2)),
            icUIView.centerYAnchor.constraint(equalTo: nativeAdView.centerYAnchor)
        ])
        
        if let iconView = iconView {
            iconView.removeFromSuperview()
            iconView.image = nativeAd.icon?.image
            iconView.layer.cornerRadius = 8
            iconView.clipsToBounds = true
            icUIView.addSubview(iconView)
            iconView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconView.topAnchor.constraint(equalTo: icUIView.topAnchor),
                iconView.bottomAnchor.constraint(equalTo: icUIView.bottomAnchor),
                iconView.leadingAnchor.constraint(equalTo: icUIView.leadingAnchor),
                iconView.trailingAnchor.constraint(equalTo: icUIView.trailingAnchor)
            ])
        }
        
        if let headlineView = headlineView {
            headlineView.text = nativeAd.headline
            headlineView.font = configuration.headlineStyle.font
            headlineView.numberOfLines = configuration.headlineStyle.numberOfLines
            headlineView.textColor = configuration.headlineStyle.textColor.toUIColor()
            
            headlineView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headlineView.widthAnchor.constraint(equalToConstant: Utils.dp(181)),
                headlineView.heightAnchor.constraint(equalToConstant: Utils.dp(17)),
                headlineView.topAnchor.constraint(equalTo: icUIView.topAnchor),
                headlineView.leadingAnchor.constraint(equalTo: icUIView.trailingAnchor, constant: Utils.dp(10))
            ])
        }
        
        if let bodyView = bodyView {
            bodyView.text = nativeAd.body
            bodyView.font = configuration.bodyStyle.font
            bodyView.textColor = configuration.bodyStyle.textColor.toUIColor()
            bodyView.numberOfLines = configuration.bodyStyle.numberOfLines
            
            bodyView.translatesAutoresizingMaskIntoConstraints = false
            var bodyConstraints: [NSLayoutConstraint] = [
                bodyView.widthAnchor.constraint(equalToConstant: Utils.dp(181)),
                bodyView.heightAnchor.constraint(equalToConstant: Utils.dp(28)),
                bodyView.leadingAnchor.constraint(equalTo: icUIView.trailingAnchor, constant: Utils.dp(10))
            ]
            if let headlineView = headlineView {
                bodyConstraints.append(bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor))
            } else {
                bodyConstraints.append(bodyView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: Utils.dp(3)))
            }
            NSLayoutConstraint.activate(bodyConstraints)
        }
        
        if let callToActionView = callToActionView {
            let title = (nativeAd.callToAction?.prefix(1).uppercased() ?? "") + (nativeAd.callToAction?.dropFirst().lowercased() ?? "")
            callToActionView.setTitle(title, for: .normal)
            callToActionView.titleLabel?.font = configuration.callActionStyle.font
            callToActionView.titleLabel?.textColor = .black
            callToActionView.colors = configuration.callActionStyle.backgroundColor
            callToActionView.layer.cornerRadius = min(configuration.callActionStyle.cornerRadius, configuration.callActionStyle.height / 2 + 1)
            callToActionView.setTitleColor(configuration.callActionStyle.textColor.toUIColor(), for: .normal)
            
            callToActionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                callToActionView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-16)),
                callToActionView.heightAnchor.constraint(equalToConstant: Utils.dp(36)),
                callToActionView.widthAnchor.constraint(equalToConstant: Utils.dp(96)),
                callToActionView.centerYAnchor.constraint(equalTo: nativeAdView.centerYAnchor)
            ])
        }
    }
}
