# FidraAds

FidraAds là một thư viện quảng cáo tích hợp với Google AdMob, cung cấp các loại quảng cáo phổ biến cho ứng dụng iOS. Thư viện này giúp đơn giản hóa quy trình tích hợp quảng cáo và quản lý hiển thị thông qua Remote Config.

## Cài đặt

### Swift Package Manager

Thêm FidraAds vào file `Package.swift` của dự án:

```swift
dependencies: [
    .package(url: "https://gitlab.volio.vn/fidra/libs/fidra-ads-swift", from: "1.0.0")
]

targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "FidraAds", package: "fidra-ads-swift")
        ]
    )
]
```

### Thiết lập ban đầu

Thêm đoạn code sau vào `AppDelegate` hoặc `SceneDelegate` để khởi tạo Mobile Ads:

```swift
import FidraAnalytics

class AppDelegate: FidraDelegate {
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Các thiết lập ứng dụng khác
        super.application(application, didFinishLaunchingWithOptions: launchOptions)

        // Tải cấu hình quảng cáo
        Task {
            await FidraRemoteConfigAds.shared.loadInitialConfig()
        }

        return true
    }
}
```

## Các loại quảng cáo hỗ trợ

### 1. Quảng cáo xen kẽ (Interstitial)

Quảng cáo toàn màn hình hiển thị trong các điểm chuyển tiếp tự nhiên của ứng dụng. Quảng cáo này thường được hiển thị tại các thời điểm chuyển màn hình hoặc kết thúc một hành động trong ứng dụng.

Tính năng chính:

- Tự động tải lại quảng cáo sau khi hiển thị
- Hỗ trợ cấu hình thời gian làm mới quảng cáo thông qua Remote Config
- Tích hợp dễ dàng với NavigationMiddleware để quản lý luồng hiển thị
- Có các callback để theo dõi trạng thái tải và hiển thị quảng cáo
- Tránh hiển thị chồng chéo với các loại quảng cáo khác (Open Ad, Reward)

**Các thuộc tính và phương thức public:**

- `static var isShowing: Bool`: Kiểm tra xem quảng cáo Interstitial có đang được hiển thị hay không.
- `var context: String`: Chuỗi ngữ cảnh (placement) dùng cho mục đích tracking.
- `var timeRefreshInterstitial: Int`: Thời gian chờ tự động load lại quảng cáo (mặc định 30 giây).
- `func setTimeRefreshInterstitial(_ timeRefreshInterstitial: Int)`: Thay đổi thời gian làm mới quảng cáo.
- `func loadAd(adUnitId: String, enableAds: Bool? = true, isAutoLoad: Bool? = false)`: Tải quảng cáo. Nếu `enableAds` là `false` hoặc `adUnitId` rỗng thì sẽ tự gọi callback `onResultFinally`.
- `func showAd(adUnitId: String, enableAds: Bool? = true, isAutoLoad: Bool? = true)`: Hiển thị quảng cáo. Nếu `isAutoLoad` = `true`, quảng cáo sẽ tự động load lại ngầm qua Timer sau khi bị đóng.

**Các Callbacks hỗ trợ:**

- `onAdLoadSuccess`: Gọi khi tải quảng cáo thành công.
- `onAdShowing`: Gọi khi bắt đầu hiển thị quảng cáo lên màn hình.
- `onAdDismiss`: Gọi khi người dùng đóng (dismiss) quảng cáo.
- `onAdError`: Gọi khi quảng cáo gặp lỗi trong lúc hiển thị.
- `onResultFinally`: Luôn được gọi khi tiến trình quảng cáo kết thúc (đã đóng, lỗi, không hiển thị được, hoặc `enableAds` = `false`).

Ví dụ tích hợp:

```swift
import FidraAds

// Tùy chỉnh cấu hình (Tuỳ chọn)
AdsInterstitial.shared.context = "Level_Complete"
AdsInterstitial.shared.setTimeRefreshInterstitial(45)

// Tải quảng cáo
Task {
    await AdsInterstitial.shared.loadAd(adUnitId: "YOUR_AD_UNIT_ID", enableAds: true, isAutoLoad: false)
}

// Thiết lập callback
AdsInterstitial.shared.onAdLoadSuccess = {
    print("Quảng cáo đã tải thành công")
}

AdsInterstitial.shared.onAdShowing = {
    print("Quảng cáo đang hiển thị")
}

AdsInterstitial.shared.onAdDismiss = {
    print("Người dùng đã đóng quảng cáo")
}

AdsInterstitial.shared.onResultFinally = {
    print("Tiến trình quảng cáo đã kết thúc (thành công hoặc thất bại)")
    // Thực hiện hành động tiếp theo của luồng ứng dụng
}

// Hiển thị quảng cáo
AdsInterstitial.shared.showAd(adUnitId: "YOUR_AD_UNIT_ID", enableAds: true, isAutoLoad: true)
```

#### Trường hợp quảng cáo inter id chung

Trong phần routing khai báo middleware

```

```

### 2. Quảng cáo khi mở ứng dụng (Open Ad)

Quảng cáo toàn màn hình hiển thị khi người dùng mở ứng dụng, tạo cơ hội hiển thị quảng cáo ngay khi người dùng mở ứng dụng.

Tính năng chính:

- Tự động xử lý timeout khi tải quảng cáo
- Tránh hiển thị chồng chéo với quảng cáo khác
- Hỗ trợ bật/tắt thông qua Remote Config

**Các thuộc tính và phương thức public:**

- `static var isShowing: Bool`: Kiểm tra xem quảng cáo Open Ad có đang hiển thị không.
- `var context: String`: Chuỗi ngữ cảnh (placement) để tracking.
- `func loadAdAndShow(adUnitId: String, enableAds: Bool? = true) async`: Load quảng cáo (có timeout 10 giây) và tự động show ngay khi load xong.
- `func showAd(remoteConfigEnable: Bool? = true)`: Hiển thị quảng cáo Open Ad đã load.

**Các Callbacks hỗ trợ:**

- `onResultFinally`: Được gọi khi quảng cáo đóng lại, hoặc khi quá trình load/show thất bại, hoặc bị bỏ qua do cài đặt.

Ví dụ tích hợp:

```swift
import FidraAds

AdsOpen.shared.context = "App_Launch"

// Tải và hiển thị quảng cáo ngay khi sẵn sàng
Task {
    await AdsOpen.shared.loadAdAndShow(adUnitId: "YOUR_AD_UNIT_ID", enableAds: true)
}

// Thiết lập callback
AdsOpen.shared.onResultFinally = {
    print("Quảng cáo Open đã đóng hoặc không thể hiển thị")
    // Thực hiện hành động sau khi quảng cáo đóng
}
```

### 3. Quảng cáo nhận thưởng (Reward)

Quảng cáo tương tác cho phép người dùng xem để nhận phần thưởng trong ứng dụng.

Tính năng chính:

- Hỗ trợ cơ chế phần thưởng
- Tự động xử lý timeout khi tải
- Có callback để xác nhận người dùng đã xem hoàn thành hay thoát ngang.

**Các thuộc tính và phương thức public:**

- `static var isShowing: Bool`: Kiểm tra Reward Ad có đang hiển thị không.
- `var context: String`: Chuỗi ngữ cảnh (placement) để tracking.
- `func loadAd(adUnitId: String, timeout: TimeInterval = 10) async`: Tải quảng cáo với hỗ trợ tự động timeout nếu mạng chậm.
- `func showAd(adUnitId: String, remoteConfigEnable: Bool? = true)`: Hiển thị quảng cáo Reward.

**Các Callbacks hỗ trợ:**

- `onAdLoadSuccess`: Gọi khi tải xong quảng cáo.
- `onLoadFailed`: Gọi khi tải quảng cáo thất bại (do lỗi hoặc timeout).
- `onAdRewarded: ((Int) -> Void)?`: Gọi khi người dùng được thưởng (đã xem đủ thời lượng yêu cầu), trả về số lượng tiền/điểm thưởng.
- `onAdCompleted: ((Bool) -> Void)?`: Trả về `true` nếu user xem hết video (done), trả về `false` nếu user tắt sớm (exit/quit).
- `onResultFinally`: Luôn được gọi khi tiến trình quảng cáo kết thúc.

Ví dụ tích hợp:

```swift
import FidraAds

AdsReward.shared.context = "Store_Free_Coins"

// Tải quảng cáo
Task {
    await AdsReward.shared.loadAd(adUnitId: "YOUR_AD_UNIT_ID", timeout: 10)
}

// Thiết lập callback
AdsReward.shared.onAdLoadSuccess = {
    print("Quảng cáo Reward đã tải thành công")
}

AdsReward.shared.onAdRewarded = { amount in
    print("Người dùng đã nhận \(amount) phần thưởng")
    // Cấp phần thưởng cho người dùng ở đây
}

AdsReward.shared.onAdCompleted = { isDone in
    if isDone {
        print("Người dùng đã xem hết quảng cáo")
    } else {
        print("Người dùng đã thoát ngang quảng cáo")
    }
}

AdsReward.shared.onLoadFailed = {
    print("Quảng cáo Reward không thể tải")
}

AdsReward.shared.onResultFinally = {
    print("Tiến trình Reward Ad đã kết thúc")
}

// Hiển thị quảng cáo
AdsReward.shared.showAd(adUnitId: "YOUR_AD_UNIT_ID", remoteConfigEnable: true)
```

### 4. Quảng cáo Banner

Quảng cáo hiển thị ở góc màn hình, thường là ở trên cùng hoặc dưới cùng.

Tính năng chính:

- Hỗ trợ nhiều loại kích thước (thông thường, lớn, thích ứng)
- Hỗ trợ quảng cáo có thể thu gọn (collapsible)
- Tự động điều chỉnh kích thước khi xoay màn hình

**Cấu hình tuỳ biến bổ sung (Parameters):**

- `timeRefresh`: (Double) Thiết lập thời gian auto-refresh banner ad tính theo giây (Mặc định: 30).
- `handleShowLoading`: Callback tuỳ chọn được gọi khi banner bắt đầu tiến trình load nếu `isEnabledShowLoading` = true.
- `endLoading: ((Error?) -> Void)?`: Callback trả về thông tin `Error` nếu tải quảng cáo thất bại hoặc `nil` nếu load thành công.

Ví dụ tích hợp:

```swift
import FidraAds
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            // Nội dung của bạn
            Spacer()
            // Banner quảng cáo ở dưới cùng
            AdsBannerView(
                adUnitID: "YOUR_AD_UNIT_ID",
                typeBannerAd: .adaptiveBanner,
                positionBannerCollapse: "bottom",
                currentScreen: "HomeScreen",
                isEnabledShowLoading: true,
                timeRefresh: 45, // Tự refresh mỗi 45 giây
                handleShowLoading: {
                    print("Bắt đầu load Banner...")
                },
                endLoading: { error in
                    if let err = error {
                        print("Banner load lỗi: \(err.localizedDescription)")
                    } else {
                        print("Banner load thành công!")
                    }
                }
            )
        }
    }
}
```

### 5. Quảng cáo Rewarded Interstitial

Quảng cáo kết hợp trải nghiệm toàn màn hình (như Interstitial) với cơ chế tặng thưởng (như Reward). Người dùng không bắt buộc phải xem để sử dụng app, nhưng nếu xem hết sẽ có phần thưởng.

Tính năng chính:

- Tương tự như Reward nhưng tự động hiển thị mà không cần người dùng thao tác click vào nút "Xem quảng cáo".
- Tuân thủ luồng timer giống AdsReward.

**Các thuộc tính và phương thức public:**

- Cũng tương tự `AdsReward` bao gồm: `isShowing`, `context`, `loadAd(adUnitId:timeout:)`, `showAd(adUnitId:remoteConfigEnable:)` và đầy đủ các callback `onAdLoadSuccess`, `onAdRewarded`, `onAdCompleted`, `onLoadFailed`, `onResultFinally`.

Ví dụ tích hợp:

```swift
import FidraAds

AdsRewardedInterstitial.shared.context = "End_of_Level_Bonus"

Task {
    await AdsRewardedInterstitial.shared.loadAd(adUnitId: "YOUR_AD_UNIT_ID", timeout: 15)
}

AdsRewardedInterstitial.shared.onAdRewarded = { amount in
    print("Nhận thêm phần thưởng cuối vòng chơi: \(amount)")
}

AdsRewardedInterstitial.shared.onResultFinally = {
    print("Tiếp tục sang vòng mới")
}

AdsRewardedInterstitial.shared.showAd(adUnitId: "YOUR_AD_UNIT_ID", remoteConfigEnable: true)
```

### 6. Quảng cáo tự nhiên (Native)

Quảng cáo được thiết kế để hòa nhập với giao diện ứng dụng, cung cấp trải nghiệm không xâm lấn cho người dùng.

Tính năng chính:

- Tùy chỉnh hoàn toàn giao diện (màu sắc, font chữ, góc bo tròn)
- Hỗ trợ nhiều loại bố cục (với media hoặc không)
- Tích hợp dễ dàng với SwiftUI

**Cấu hình tuỳ biến bổ sung (Parameters):**
Bổ sung các tham số vào View `AdsNativeView` khi khởi tạo:

- `isSelectOption: Binding<Bool>?`: Trạng thái tuỳ chọn.
- `collapsible: Bool`: Cho phép thu gọn native ads.
- `currentScreen: String`: Chuỗi ngữ cảnh tracking hiện tại.
- `refreshTimeInSeconds: Double`: Cấu hình thời gian tải lại quảng cáo (Mặc định: 30s).
- `enableAutoRefresh: Bool`: Kích hoạt tự động tải lại quảng cáo (Mặc định: `false`).
- `onAdLoaded: ((Bool) -> Void)?`: Callback trả về trạng thái khi tải xong quảng cáo.
- `onDismiss: (() -> Void)?`: Callback khi dismiss quảng cáo (thường dùng cho `collapsible`).

**Các Modifiers (View extensions):**

- Bổ sung modifier: `.adBorder(width: CGFloat, color: Color)`: Hỗ trợ tạo viền cho Ad.

#### Các loại bố cục Native Ads

FidraAds hỗ trợ các loại bố cục quảng cáo Native sau:

**Small Layouts:**

| Layout  | Enum      | Mô tả                                                          |
| ------- | --------- | -------------------------------------------------------------- |
| Small   | `.small`  | Kích thước nhỏ, lý tưởng cho danh sách hoặc không gian hạn chế |
| Small 2 | `.small2` | Biến thể Small với bố cục khác                                 |
| Small 3 | `.small3` | Biến thể Small với bố cục khác                                 |
| Small 4 | `.small4` | Biến thể Small với bố cục khác                                 |
| Small 5 | `.small5` | Biến thể Small với bố cục khác                                 |
| Small 6 | `.small6` | Biến thể Small với bố cục khác                                 |
| Small 7 | `.small7` | Native small CameraBeauty (Ads-S): icon trái, badge Ad + headline, body 2 dòng, CTA phải — xem [ảnh tham chiếu](docs/images/native/small7-ads-s.png) |

**Small 7 — tham chiếu Figma (CameraBeauty Ads-S):**

![Native Small 7 — Ads-S](docs/images/native/small7-ads-s.png)

- Figma: [Component/Light-theme/Ads-S](https://www.figma.com/design/GC98Ly03IYwABuOOuVvtDP/CameraBeauty_Iphone_UI_26?node-id=6497-3944)
- Enum: `.small7` · Layout: `SmallNativeAdLayout7`
- Kích thước khung: **370×64** (scale `@2x` trong ảnh trên)

**Medium Layouts:**

| Layout   | Enum       | Mô tả                                           |
| -------- | ---------- | ----------------------------------------------- |
| Medium   | `.medium`  | Kích thước trung bình, phù hợp với nhiều vị trí |
| Medium 1 | `.medium1` | Biến thể Medium với bố cục khác                 |
| Medium 2 | `.medium2` | Biến thể Medium với bố cục khác                 |

**Medium With Media Layouts:**

| Layout              | Enum                | Mô tả                                                  |
| ------------------- | ------------------- | ------------------------------------------------------ |
| Medium With Media   | `.mediumWithMedia`  | Quảng cáo với hình ảnh/video lớn và thông tin bên cạnh |
| Medium With Media 2 | `.mediumWithMedia2` | Hình ảnh/video lớn ở phía dưới, thông tin bên trên     |
| Medium With Media 3 | `.mediumWithMedia3` | Biến thể Medium With Media với bố cục khác             |
| Medium With Media 4 | `.mediumWithMedia4` | Biến thể Medium With Media với bố cục khác             |

**Collapsible Layouts:**

| Layout        | Enum            | Mô tả                                                                       |
| ------------- | --------------- | --------------------------------------------------------------------------- |
| Collapsible   | `.collapsible`  | Quảng cáo collapse native                                                   |
| Collapsible 2 | `.collapsible2` | Collapse native có media ở trên, image/header/body/ctn nằm trên cùng 1 hàng |
| Collapsible 3 | `.collapsible3` | Biến thể Collapsible với bố cục khác                                        |
| Collapsible 4 | `.collapsible4` | Biến thể Collapsible với bố cục khác                                        |

**Các layout khác:**

| Layout | Enum              | Mô tả                    |
| ------ | ----------------- | ------------------------ |
| Large  | `.large`          | Quảng cáo kích thước lớn |
| Banner | `.banner`         | Bố cục dạng banner       |
| Feed   | `.feed`           | Bố cục dạng feed         |
| Custom | `.custom(String)` | Bố cục tùy chỉnh         |

Ví dụ tích hợp:

```swift
import FidraAds
import SwiftUI

struct ContentView: View {
    @State private var isCollapsed: Bool = false

    var body: some View {
        VStack {
            // Quảng cáo Native với tùy chỉnh giao diện
            AdsNativeView(
                adUnitId: "YOUR_AD_UNIT_ID",
                collapsible: true,
                currentScreen: "Home_Screen",
                onAdLoaded: { isSuccess in
                    print("Native Ad load status: \(isSuccess)")
                },
                onDismiss: {
                    print("Native Ad dismissed")
                    isCollapsed = true
                },
                refreshTimeInSeconds: 45,
                enableAutoRefresh: true
            )
            .adBackground(Color.gray.opacity(0.1))
            .adLayoutType(.mediumWithMedia)
            .adChoicesPosition(.topRight)
            .adCornerRadius(12)
            .adBorder(width: 1, color: .gray)
            .adHeadlineStyle(HeadlineStyle(
                numberOfLines: 2,
                font: UIFont.systemFont(ofSize: 18, weight: .bold),
                textColor: .black
            ))
            .adBodyStyle(BodyStyle(
                numberOfLines: 3,
                font: UIFont.systemFont(ofSize: 14, weight: .regular),
                textColor: .gray
            ))
            .adBadgeStyle(AdBadgeStyle(
                text: "Quảng cáo",
                textColor: .white,
                backgroundColor: .black.opacity(0.6)
            ))
            .adCallActionStyle(CallActionStyle(
                textColor: .white,
                backgroundColor: [.blue, .purple],
                cornerRadius: 8
            ))
            .adIconSize(CGSize(width: 48, height: 48))
            .adMediaSize(CGSize(width: 152, height: 180))

            // Nội dung khác
        }
    }
}
```

## Tích hợp với Remote Config

FidraAds hỗ trợ tích hợp với Firebase Remote Config để dễ dàng quản lý cấu hình quảng cáo từ xa mà không cần cập nhật ứng dụng.

### Thiết lập Remote Config

Cấu trúc của cấu hình quảng cáo trên Remote Config:

```json
{
  "ad_unit_id_configs": {
    "banner_home": {
      "adId": "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX",
      "adIdTest": "ca-app-pub-3940256099942544/2934735716",
      "isDisplayForUser": true,
      "isDisplayForReview": false
    },
    "interstitial_level_complete": {
      "adId": "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX",
      "adIdTest": "ca-app-pub-3940256099942544/4411468910",
      "isDisplayForUser": true,
      "isDisplayForReview": false
    }
  },
  "time_refresh_banner": 45,
  "time_refresh_interstitial": 30
}
```

### Sử dụng với Remote Config

```swift
// Kiểm tra nếu quảng cáo được bật
let isEnabled = FidraRemoteConfigAds.shared.isEnableAds("interstitial_level_complete")

// Lấy ID quảng cáo (tự động chọn ID thật hoặc ID test tùy vào trạng thái review)
let adUnitId = FidraRemoteConfigAds.shared.idAds("interstitial_level_complete")

// Lấy thời gian làm mới của quảng cáo
let refreshTime = FidraRemoteConfigAds.shared.timeRefreshInterstitial
```

## Theo dõi doanh thu quảng cáo

FidraAds tích hợp với Firebase Analytics và AppsFlyer để theo dõi doanh thu quảng cáo:

```swift
import FidraAnalytics

// Thiết lập Analytics
FidraAnalytics.shared.configure(
    appsFlyerDevKey: "YOUR_APPS_FLYER_DEV_KEY",
    appleAppID: "YOUR_APPLE_APP_ID",
    isDebug: true
)

// FidraAds sẽ tự động ghi lại các sự kiện doanh thu quảng cáo
```

## Event Bus Tracking

FidraAds sử dụng event bus để tách biệt tracking logic ra ngoài module. Điều này giúp module độc lập và có thể tích hợp với bất kỳ tracking system nào.

### Subscribe vào events

```swift
import FidraAds

let subscriptionId = AdTrackingEventBus.shared.subscribe { event in
    switch event.type {
    case .request(let adFormat, let adNetwork, let adUnitId, let isLoad, let errorCode, let retryCount, let loadTime):
        print("Ad request: \(adFormat), network: \(adNetwork), unit: \(adUnitId), loaded: \(isLoad)")
        if let errorCode = errorCode {
            print("Error code: \(errorCode)")
        }
        print("Load time: \(loadTime)ms")

    case .click(let adFormat, let adNetwork, let adUnitId, let placement):
        print("Ad clicked: \(adFormat), network: \(adNetwork), unit: \(adUnitId), placement: \(placement)")

    case .impression(let adFormat, let adNetwork, let adUnitId, let placement, let isShow, let errorCode, let value):
        print("Ad impression: \(adFormat), network: \(adNetwork), unit: \(adUnitId), shown: \(isShow)")
        if let errorCode = errorCode {
            print("Error code: \(errorCode)")
        }
        print("Value: \(value)")

    case .complete(let adFormat, let adNetwork, let adUnitId, let adDuration, let placement, let endType):
        print("Ad completed: \(adFormat), network: \(adNetwork), duration: \(adDuration)ms")
        if let endType = endType {
            print("End type: \(endType)")
        }

    case .revenue(let adUnit, let adSourceName, let revenue, let currency):
        print("Ad revenue: \(adUnit), source: \(adSourceName), revenue: \(revenue) \(currency)")
    }
}
```

### Unsubscribe

```swift
AdTrackingEventBus.shared.unsubscribe(subscriptionId)
```

### Ví dụ tích hợp với FidraAnalytics

```swift
import FidraAds
import FidraAnalytics

func convertAdFormat(_ format: AdFormat) -> AdEvent.AdFormat {
    switch format {
    case .banner: return .banner
    case .interstitial: return .interstitial
    case .rewarded: return .rewarded
    case .open: return .open
    case .native: return .native
    case .collapseNative: return .collapseNative
    }
}

let subscriptionId = AdTrackingEventBus.shared.subscribe { event in
    switch event.type {
    case .request(let adFormat, let adNetwork, let adUnitId, let isLoad, let errorCode, let retryCount, let loadTime):
        let adEvent = AdEvent.request(
            adFormat: convertAdFormat(adFormat),
            adNetwork: adNetwork,
            adUnitId: adUnitId,
            isLoad: isLoad,
            errorCode: errorCode ?? "",
            retryCount: retryCount,
            loadTime: loadTime
        )
        FidraAnalytics.shared.logAdEvent(adEvent)

    case .click(let adFormat, let adNetwork, let adUnitId, let placement):
        let adEvent = AdEvent.click(
            adFormat: convertAdFormat(adFormat),
            adNetwork: adNetwork,
            adUnitId: adUnitId,
            placement: placement
        )
        FidraAnalytics.shared.logAdEvent(adEvent)

    case .impression(let adFormat, let adNetwork, let adUnitId, let placement, let isShow, let errorCode, let value):
        let adEvent = AdEvent.impression(
            adFormat: convertAdFormat(adFormat),
            adNetwork: adNetwork,
            adUnitId: adUnitId,
            placement: placement,
            isShow: isShow,
            errorCode: errorCode ?? "",
            value: value
        )
        FidraAnalytics.shared.logAdEvent(adEvent)

    case .complete(let adFormat, let adNetwork, let adUnitId, let adDuration, let placement, let endType):
        let adEvent = AdEvent.complete(
            adFormat: convertAdFormat(adFormat),
            adNetwork: adNetwork,
            adUnitId: adUnitId,
            adDuration: adDuration,
            placement: placement,
            endType: endType
        )
        FidraAnalytics.shared.logAdEvent(adEvent)

    case .revenue(let adUnit, let adSourceName, let revenue, let currency):
        FidraAnalytics.shared.logAdRevenueAppsFlyer(
            adUnit: adUnit,
            adSourceName: adSourceName,
            revenue: revenue,
            currency: currency
        )
    }
}
```

### Event Types

- **request**: Emitted khi ad được request (load thành công hoặc thất bại)
  - Parameters: `adFormat`, `adNetwork`, `adUnitId`, `isLoad`, `errorCode`, `retryCount`, `loadTime`
- **click**: Emitted khi user click vào ad
  - Parameters: `adFormat`, `adNetwork`, `adUnitId`, `placement`
- **impression**: Emitted khi ad được hiển thị
  - Parameters: `adFormat`, `adNetwork`, `adUnitId`, `placement`, `isShow`, `errorCode`, `value`
- **complete**: Emitted khi ad được đóng (hoàn thành hoặc bỏ dở)
  - Parameters: `adFormat`, `adNetwork`, `adUnitId`, `adDuration`, `placement`, `endType`
- **revenue**: Emitted khi có revenue từ ad
  - Parameters: `adUnit`, `adSourceName`, `revenue`, `currency`

### Lưu ý

- Event bus là thread-safe và sử dụng concurrent queue
- Tất cả events được dispatch trên main thread
- Nên unsubscribe khi không cần nữa để tránh memory leaks
- Có thể subscribe nhiều handlers cùng lúc

## GDPR

FidraAds tích hợp Google UMP (User Messaging Platform) để quản lý consent theo quy định GDPR.

### Khởi tạo UMP Consent

```swift
import FidraAds

UMPConsentManager.shared.initialize(underAge: false, debugMode: false) { canShowAds in
    if canShowAds {
        // Có thể hiển thị quảng cáo
        print("Ads enabled")
    } else {
        // Người dùng từ chối consent, không hiển thị ads
        print("Ads disabled by user consent")
    }
}
```

### Các thuộc tính và phương thức

| API                                          | Mô tả                                                       |
| -------------------------------------------- | ----------------------------------------------------------- |
| `initialize(underAge:debugMode:completion:)` | Khởi tạo và kiểm tra consent, tự động hiển thị form nếu cần |
| `showForm(complete:)`                        | Hiển thị consent form thủ công                              |
| `canShowAds`                                 | Kiểm tra người dùng có cho phép hiển thị ads không          |
| `isConsentRequired`                          | Kiểm tra có yêu cầu consent không                           |
| `isCountryInEEA`                             | Kiểm tra thiết bị có ở khu vực EEA không                    |
| `reset()`                                    | Reset trạng thái consent                                    |

### FormResult

Callback `showForm` trả về các trạng thái sau:

- `.success` — Người dùng đã hoàn thành consent form
- `.loadFailed(Error)` — Không thể tải form
- `.presentFailed(Error)` — Không thể hiển thị form
- `.formClosed` — Form đã đóng
- `.timeout` — Timeout sau 10 giây

## Yêu cầu hệ thống

- iOS 16.0+
- Swift 5.9+
- Xcode 15.0+

## Phụ thuộc

- [GoogleMobileAds](https://github.com/googleads/swift-package-manager-google-mobile-ads) (AdMob) >= 12.0.0
- [GoogleUserMessagingPlatform](https://github.com/googleads/swift-package-manager-google-user-messaging-platform) (UMP/GDPR) >= 3.0.0

## Giấy phép

Copyright © 2025 Fidra. Mọi quyền được bảo lưu.
