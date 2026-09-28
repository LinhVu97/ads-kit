import SwiftUI
import GoogleMobileAds
import UIKit

public struct NativeAdViewRepresentable: UIViewRepresentable {
    let nativeAd: NativeAd
    let viewController: UIViewController
    let configuration: NativeAdConfiguration
    let layoutType: NativeAdLayoutType
    var isSelectOption: Binding<Bool>?
    var onSizeChange: ((CGSize) -> Void)? = nil
    var collapsibleHeight: CGFloat?

    public init(nativeAd: NativeAd, viewController: UIViewController, configuration: NativeAdConfiguration, layoutType: NativeAdLayoutType, isSelectOption: Binding<Bool>? = nil, onSizeChange: ((CGSize) -> Void)? = nil, collapsibleHeight: CGFloat? = nil) {
        self.nativeAd = nativeAd
        self.viewController = viewController
        self.configuration = configuration
        self.layoutType = layoutType
        self.isSelectOption = isSelectOption
        self.onSizeChange = onSizeChange
        self.collapsibleHeight = collapsibleHeight
    }
    
    private func getLayoutBuilder() -> NativeAdLayoutBuilder {
        switch layoutType {
        case .small:
            return SmallNativeAdLayout()
        case .small2:
            return SmallNativeAdLayout2()
        case .small3:
            return SmallNativeAdLayout3()
        case .small4:
            return SmallNativeAdLayout4()
        case .small5:
            return SmallNativeAdLayout5()
        case .small6:
            return SmallNativeAdLayout6()
        case .small7:
            return SmallNativeAdLayout7()
        case .medium:
            return MediumNativeAdLayout()
        case .mediumWithMedia:
            return MediumWithMediaNativeAdLayout()
        case .large:
            return LargeNativeAdLayout()
        case .medium1:
            return MediumNativeAdLayout1()
        case .medium2:
            return MediumNativeAdLayout2()
        case .mediumWithMedia2:
            return MediumWithMediaNativeAdLayout2()
        case .mediumWithMedia3:
            return MediumWithMediaNativeAdLayout3()
        case .mediumWithMedia4:
            return MediumWithMediaNativeAdLayout4()
        case .mediumWithMediaCTAFirst:
            return MediumWithMediaCTAFirstNativeAdLayout()
        case .textOnly:
            return TextOnlyNativeAdLayout()
        case .smallCompact:
            return SmallCompactNativeAdLayout()
        case .fullscreenVideo:
            return FullscreenVideoNativeAdLayout()
        case .fullscreenVideo2:
            return FullscreenVideoNativeAdLayout2()
        case .collapsible:
            return CollapsibleNativeAdLayout()
        case .collapsible2:
            return CollapsibleNativeAdLayout2()
        case .collapsible3:
            return CollapsibleNativeAdLayout3()
        case .collapsible4:
            return CollapsibleNativeAdLayout4()
         case .collapsible5:
            return CollapsibleNativeAdLayout5()
        case .smallRadial:
            return SmallNativeAdLayoutRadial()
          case .collapsibleRadial:
            return CollapsibleNativeAdLayoutRadial()
        default:
            return LargeNativeAdLayout()
        }
    }
    
    public func makeUIView(context: Context) -> NativeAdView {
        let nativeAdView = NativeAdView()
        // Đảm bảo NativeAdView chính có thể nhận tương tác
        nativeAdView.isUserInteractionEnabled = true
        
        let layoutBuilder = getLayoutBuilder()
        layoutBuilder.setupLayout(nativeAdView: nativeAdView, nativeAd: nativeAd, configuration: configuration)
        nativeAdView.nativeAd = nativeAd
        nativeAdView.isUserInteractionEnabled = true
        return nativeAdView
    }
    
    public func updateUIView(_ nativeAdView: NativeAdView, context: Context) {
        if let height = collapsibleHeight, height > 0 {
            DispatchQueue.main.async {
                nativeAdView.setNeedsLayout()
                nativeAdView.layoutIfNeeded()
            }
        }
        DispatchQueue.main.async {
            let targetSize = nativeAdView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            onSizeChange?(targetSize)
        }
        if let isSelectOption = isSelectOption?.wrappedValue, isSelectOption {
            if let callToActionView = nativeAdView.callToActionView as? GradientNativeAdButton {
                callToActionView.colors = configuration.callActionStyle.backgroundColorActive
            }
        }
    }
}
