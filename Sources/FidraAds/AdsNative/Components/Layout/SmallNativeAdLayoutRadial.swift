import UIKit
import GoogleMobileAds

class SmallNativeAdLayoutRadial: NativeAdLayoutBuilder {
    
    func setupLayout(nativeAdView: NativeAdView, nativeAd: NativeAd, configuration: NativeAdConfiguration) {
        setupComponents(nativeAdView: nativeAdView, configuration: configuration)
        let textView = setupTextAd(nativeAdView: nativeAdView, configuration: configuration)
        
        let iconView = nativeAdView.iconView as? UIImageView
        let headlineView = nativeAdView.headlineView as? UILabel
        let bodyView = nativeAdView.bodyView as? UILabel
        let callToActionView = nativeAdView.callToActionView as? GradientNativeAdButton
        
        textView.removeFromSuperview()
        textView.text = configuration.adBadgeStyle.text
        textView.font = configuration.adBadgeStyle.font
        textView.textColor = configuration.adBadgeStyle.textColor.toUIColor()
        
        let textViewView = UIView()
        textViewView.backgroundColor = configuration.adBadgeStyle.backgroundColor.toUIColor()
        textViewView.clipsToBounds = true
        textViewView.isUserInteractionEnabled = false
        textViewView.layer.cornerRadius = Utils.dp(4)
        textViewView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        
        nativeAdView.addSubview(textViewView)
        textViewView.addSubview(textView)
        
        textViewView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textViewView.widthAnchor.constraint(greaterThanOrEqualToConstant: Utils.dp(16)),
            textViewView.heightAnchor.constraint(equalToConstant: Utils.dp(12)),
            textViewView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
            textViewView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 3)
        ])
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.centerYAnchor.constraint(equalTo: textViewView.centerYAnchor),
            textView.trailingAnchor.constraint(equalTo: textViewView.trailingAnchor, constant: Utils.dp(-3))
        ])
        
        if let iconView = iconView {
            iconView.image = nativeAd.icon?.image
            iconView.layer.cornerRadius = Utils.dp(8)
            iconView.clipsToBounds = true

            iconView.translatesAutoresizingMaskIntoConstraints = false
            // Vertical insets are minimums (not pins) + centered, so a host that
            // constrains the ad to a fixed `.frame(height:)` shorter than the natural
            // content can't force a broken/overlapping layout.
            let iconTop = iconView.topAnchor.constraint(greaterThanOrEqualTo: nativeAdView.topAnchor, constant: Utils.dp(12))
            iconTop.priority = .defaultHigh
            let iconBottom = iconView.bottomAnchor.constraint(lessThanOrEqualTo: nativeAdView.bottomAnchor, constant: -Utils.dp(12))
            iconBottom.priority = .defaultHigh
            NSLayoutConstraint.activate([
                iconView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(16)),
                iconView.centerYAnchor.constraint(equalTo: nativeAdView.centerYAnchor),
                iconTop,
                iconBottom,
                iconView.widthAnchor.constraint(equalToConstant: configuration.iconSize.width),
                iconView.heightAnchor.constraint(equalToConstant: configuration.iconSize.width)
            ])
        }

        // Headline + body live in a vertically-centered stack. Centering (instead of
        // pinning the headline to the top) means a too-short container clips the block
        // evenly rather than slicing the headline's glyphs. Fonts/colors come from
        // `configuration` so the host actually controls text size.
        if let headlineView = headlineView {
            headlineView.text = nativeAd.headline
            headlineView.font = configuration.headlineStyle.font ?? .systemFont(ofSize: 14, weight: .semibold)
            headlineView.textColor = configuration.headlineStyle.textColor.toUIColor()
            headlineView.numberOfLines = configuration.headlineStyle.numberOfLines
            headlineView.lineBreakMode = configuration.headlineStyle.truncationMode
            headlineView.adjustsFontSizeToFitWidth = false
            headlineView.setContentCompressionResistancePriority(.required, for: .vertical)
        }

        if let bodyView = bodyView {
            bodyView.text = nativeAd.body
            bodyView.font = configuration.bodyStyle.font ?? .systemFont(ofSize: 10)
            bodyView.textColor = configuration.bodyStyle.textColor.toUIColor()
            bodyView.numberOfLines = configuration.bodyStyle.numberOfLines
        }

        let textStack = UIStackView(arrangedSubviews: [headlineView, bodyView].compactMap { $0 })
        textStack.axis = .vertical
        textStack.spacing = Utils.dp(2)
        textStack.alignment = .fill
        textStack.isUserInteractionEnabled = false
        textStack.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.addSubview(textStack)
        let stackTop = textStack.topAnchor.constraint(greaterThanOrEqualTo: nativeAdView.topAnchor, constant: Utils.dp(8))
        stackTop.priority = .defaultHigh
        let stackBottom = textStack.bottomAnchor.constraint(lessThanOrEqualTo: nativeAdView.bottomAnchor, constant: -Utils.dp(8))
        stackBottom.priority = .defaultHigh
        NSLayoutConstraint.activate([
            textStack.leadingAnchor.constraint(equalTo: (iconView?.trailingAnchor ?? nativeAdView.leadingAnchor), constant: Utils.dp(12)),
            textStack.trailingAnchor.constraint(equalTo: (callToActionView?.leadingAnchor ?? nativeAdView.trailingAnchor), constant: -Utils.dp(12)),
            textStack.centerYAnchor.constraint(equalTo: (iconView?.centerYAnchor ?? nativeAdView.centerYAnchor)),
            stackTop,
            stackBottom
        ])
        
        if let callToActionView = callToActionView {
            let title = (nativeAd.callToAction?.prefix(1).uppercased() ?? "") + (nativeAd.callToAction?.dropFirst().lowercased() ?? "")
            callToActionView.setTitle(title, for: .normal)
            callToActionView.titleLabel?.font = configuration.callActionStyle.font
            callToActionView.titleLabel?.textColor = .black
            callToActionView.applyRadialStyle(
                colors: configuration.callActionStyle.backgroundColor, cornerRadius: min(configuration.callActionStyle.cornerRadius,
                                                                                         configuration.callActionStyle.height / 2)
            )
            callToActionView.layer.cornerRadius = min(configuration.callActionStyle.cornerRadius, configuration.callActionStyle.height / 2)
            callToActionView.setTitleColor(configuration.callActionStyle.textColor.toUIColor(), for: .normal)
            
            callToActionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                callToActionView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-16)),
                callToActionView.centerYAnchor.constraint(equalTo: nativeAdView.centerYAnchor),
                callToActionView.widthAnchor.constraint(greaterThanOrEqualToConstant: Utils.dp(94)),
                callToActionView.heightAnchor.constraint(equalToConstant: configuration.callActionStyle.height)
            ])
        }
    }
}
