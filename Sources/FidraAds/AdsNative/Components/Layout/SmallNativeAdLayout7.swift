import UIKit
import GoogleMobileAds

/// Native small layout theo Figma CameraBeauty — Component/Light-theme/Ads-S (node 6497:3944).
/// Icon trái, badge "Ad" + headline một hàng, body 2 dòng, CTA phải.
class SmallNativeAdLayout7: NativeAdLayoutBuilder {
    func setupLayout(nativeAdView: NativeAdView, nativeAd: NativeAd, configuration: NativeAdConfiguration) {
        setupComponents(nativeAdView: nativeAdView, configuration: configuration)
        let textView = setupTextAd(nativeAdView: nativeAdView, configuration: configuration)

        let iconView = nativeAdView.iconView as? UIImageView
        let headlineView = nativeAdView.headlineView as? UILabel
        let bodyView = nativeAdView.bodyView as? UILabel
        let callToActionView = nativeAdView.callToActionView as? GradientNativeAdButton

        nativeAdView.layer.cornerRadius = Utils.dp(6)
        nativeAdView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        nativeAdView.clipsToBounds = true

        let iconContainer = UIView()
        iconContainer.backgroundColor = .gray.withAlphaComponent(0.3)
        iconContainer.layer.cornerRadius = Utils.dp(4)
        iconContainer.clipsToBounds = true
        nativeAdView.addSubview(iconContainer)

        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconContainer.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: Utils.dp(4)),
            iconContainer.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(4)),
            iconContainer.widthAnchor.constraint(equalToConstant: Utils.dp(63)),
            iconContainer.heightAnchor.constraint(equalToConstant: Utils.dp(56)),
            nativeAdView.heightAnchor.constraint(greaterThanOrEqualToConstant: Utils.dp(64))
        ])

        if let iconView = iconView {
            iconView.removeFromSuperview()
            iconView.image = nativeAd.icon?.image
            iconView.contentMode = .scaleAspectFill
            iconView.clipsToBounds = true
            iconContainer.addSubview(iconView)
            iconView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconView.topAnchor.constraint(equalTo: iconContainer.topAnchor),
                iconView.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor),
                iconView.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor),
                iconView.trailingAnchor.constraint(equalTo: iconContainer.trailingAnchor)
            ])
        }

        textView.removeFromSuperview()
        nativeAdView.addSubview(textView)
        textView.text = configuration.adBadgeStyle.text
        textView.font = configuration.adBadgeStyle.font ?? UIFont.systemFont(ofSize: 10, weight: .medium)
        textView.textColor = configuration.adBadgeStyle.textColor.toUIColor()
        textView.backgroundColor = configuration.adBadgeStyle.backgroundColor.toUIColor()
        textView.clipsToBounds = true
        textView.isUserInteractionEnabled = false
        textView.textAlignment = .center
        textView.layer.cornerRadius = Utils.dp(2)

        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.widthAnchor.constraint(greaterThanOrEqualToConstant: Utils.dp(20)),
            textView.heightAnchor.constraint(equalToConstant: Utils.dp(16)),
            textView.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: Utils.dp(4)),
            textView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(8))
        ])

        if let headlineView = headlineView {
            headlineView.text = nativeAd.headline
            headlineView.font = configuration.headlineStyle.font ?? UIFont.systemFont(ofSize: 12, weight: .medium)
            headlineView.numberOfLines = 1
            headlineView.textColor = configuration.headlineStyle.textColor.toUIColor()

            headlineView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headlineView.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: Utils.dp(4)),
                headlineView.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
                headlineView.heightAnchor.constraint(equalToConstant: Utils.dp(12))
            ])
        }

        if let bodyView = bodyView {
            bodyView.text = nativeAd.body
            bodyView.font = configuration.bodyStyle.font ?? UIFont.systemFont(ofSize: 10, weight: .regular)
            bodyView.textColor = configuration.bodyStyle.textColor.toUIColor()
            bodyView.numberOfLines = 2

            bodyView.translatesAutoresizingMaskIntoConstraints = false
            var bodyConstraints: [NSLayoutConstraint] = [
                bodyView.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
                bodyView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(28)),
                bodyView.heightAnchor.constraint(equalToConstant: Utils.dp(32))
            ]
            if let callToActionView = callToActionView {
                bodyConstraints.append(bodyView.trailingAnchor.constraint(lessThanOrEqualTo: callToActionView.leadingAnchor, constant: Utils.dp(-8)))
            } else {
                bodyConstraints.append(bodyView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-16)))
            }
            NSLayoutConstraint.activate(bodyConstraints)
        }

        if let callToActionView = callToActionView {
            callToActionView.setTitle(nativeAd.callToAction?.uppercased(), for: .normal)
            callToActionView.titleLabel?.font = configuration.callActionStyle.font ?? UIFont.systemFont(ofSize: 12, weight: .heavy)
            callToActionView.colors = configuration.callActionStyle.backgroundColor
            callToActionView.layer.cornerRadius = Utils.dp(4)
            callToActionView.setTitleColor(configuration.callActionStyle.textColor.toUIColor(), for: .normal)

            callToActionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                callToActionView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: Utils.dp(-4)),
                callToActionView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: Utils.dp(32)),
                callToActionView.widthAnchor.constraint(equalToConstant: Utils.dp(92)),
                callToActionView.heightAnchor.constraint(equalToConstant: Utils.dp(28))
            ])
        }

        if let headlineView = headlineView, let callToActionView = callToActionView {
            headlineView.trailingAnchor.constraint(lessThanOrEqualTo: callToActionView.leadingAnchor, constant: Utils.dp(-8)).isActive = true
        }
    }
}
