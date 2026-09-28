import SwiftUI

public enum AdChoicesPosition {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

public struct NativeAdConfiguration {
    // Màu sắc và kiểu dáng
    public var background: Color
    public var adViewCornerRadius: CGFloat
    public var iconSize: CGSize
    
    // Layout và cấu hình nâng cao
    public var layoutType: NativeAdLayoutType
    public var headlineStyle: HeadlineStyle
    public var bodyStyle: BodyStyle
    public var callActionStyle: CallActionStyle
    public var padding: EdgeInsets
    public var mediaSize: CGSize
    
    // Thêm cấu hình cho AdChoices
    public var adChoicesPosition: AdChoicesPosition

    // AdBadge
    public var adBadgeStyle: AdBadgeStyle

    public init(
        adChoicesPosition: AdChoicesPosition = .topRight,
        background: Color = .black,
        adViewCornerRadius: CGFloat = 8, 
        iconSize: CGSize = CGSize(width: 48, height: 48),
        layoutType: NativeAdLayoutType = .medium,
        adBadgeStyle: AdBadgeStyle = AdBadgeStyle(),
        headlineStyle: HeadlineStyle = HeadlineStyle(),
        bodyStyle: BodyStyle = BodyStyle(),
        callActionStyle: CallActionStyle = CallActionStyle(),
        padding: EdgeInsets = .init(top: 12, leading: 16, bottom: 12, trailing: 16),
        mediaSize: CGSize = CGSize(width: 152, height: 180)
    ) {
        self.background = background
        self.adViewCornerRadius = adViewCornerRadius
        self.iconSize = iconSize
        self.layoutType = layoutType
        self.headlineStyle = headlineStyle
        self.bodyStyle = bodyStyle
        self.callActionStyle = callActionStyle
        self.padding = padding
        self.mediaSize = mediaSize
        self.adChoicesPosition = adChoicesPosition
        self.adBadgeStyle = adBadgeStyle
        self.iconSize = iconSize
    }
}
