import Foundation

public enum NativeAdLayoutType {
    case small
    case smallRadial
    case small2
    case small3
    case small4
    case small5
    case small6
    case small7
    case medium
    case medium1
    case medium2
    case mediumWithMedia
    case mediumWithMedia2
    case mediumWithMedia3
    case mediumWithMedia4
    case mediumWithMediaCTAFirst
    case textOnly
    case smallCompact
    case collapsible
    case collapsible2
    case collapsible3
    case collapsibleRadial
    case collapsible4
    case collapsible5
    case large
    case fullscreenVideo
    case fullscreenVideo2
    case banner
    case feed
    case custom(String)
}

extension NativeAdLayoutType: Equatable {
    public static func == (lhs: NativeAdLayoutType, rhs: NativeAdLayoutType) -> Bool {
        switch (lhs, rhs) {
        case (.small, .small),
             (.smallRadial, .smallRadial),
             (.collapsibleRadial, .collapsibleRadial),
             (.small2, .small2),
             (.small3, .small3),
             (.small4, .small4),
             (.small5, .small5),
             (.small6, .small6),
             (.small7, .small7),
             (.medium, .medium),
             (.medium1, .medium1),
             (.medium2, .medium2),
             (.mediumWithMedia, .mediumWithMedia),
             (.mediumWithMedia2, .mediumWithMedia2),
             (.mediumWithMedia3, .mediumWithMedia3),
             (.mediumWithMedia4, .mediumWithMedia4),
             (.mediumWithMediaCTAFirst, .mediumWithMediaCTAFirst),
             (.textOnly, .textOnly),
             (.smallCompact, .smallCompact),
             (.collapsible, .collapsible),
             (.collapsible2, .collapsible2),
             (.collapsible3, .collapsible3),
             (.collapsible4, .collapsible4),
             (.collapsible5, .collapsible5),
             (.large, .large),
             (.fullscreenVideo, .fullscreenVideo),
             (.fullscreenVideo2, .fullscreenVideo2),
             (.banner, .banner),
             (.feed, .feed):
            return true
        case (.custom(let lhsValue), .custom(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}
