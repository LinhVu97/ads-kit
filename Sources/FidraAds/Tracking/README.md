# Ad Tracking Event Bus

Event bus system để tách biệt tracking logic ra ngoài module FidraAds.

## Tổng quan

Module FidraAds sử dụng event bus để emit các tracking events thay vì gọi trực tiếp tracking services. Điều này giúp module độc lập và có thể tích hợp với bất kỳ tracking system nào.

## Cách sử dụng

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

## Event Types

### request
Emitted khi ad được request (load thành công hoặc thất bại).

**Parameters:**
- `adFormat`: Loại ad (banner, interstitial, rewarded, open, native, collapseNative)
- `adNetwork`: Tên ad network (ví dụ: "Admob", "Facebook")
- `adUnitId`: ID của ad unit
- `isLoad`: 1 nếu load thành công, 0 nếu thất bại
- `errorCode`: Mã lỗi (nếu có)
- `retryCount`: Số lần retry
- `loadTime`: Thời gian load tính bằng milliseconds

### click
Emitted khi user click vào ad.

**Parameters:**
- `adFormat`: Loại ad
- `adNetwork`: Tên ad network
- `adUnitId`: ID của ad unit
- `placement`: Vị trí hiển thị ad

### impression
Emitted khi ad được hiển thị.

**Parameters:**
- `adFormat`: Loại ad
- `adNetwork`: Tên ad network
- `adUnitId`: ID của ad unit
- `placement`: Vị trí hiển thị ad
- `isShow`: 1 nếu hiển thị thành công, 0 nếu thất bại
- `errorCode`: Mã lỗi (nếu có)
- `value`: Giá trị revenue (nếu có)

### complete
Emitted khi ad được đóng (hoàn thành hoặc bỏ dở).

**Parameters:**
- `adFormat`: Loại ad
- `adNetwork`: Tên ad network
- `adUnitId`: ID của ad unit
- `adDuration`: Thời gian xem ad tính bằng milliseconds
- `placement`: Vị trí hiển thị ad
- `endType`: Loại kết thúc ("done" nếu xem hết, "quit" nếu bỏ dở, nil cho các loại khác)

### revenue
Emitted khi có revenue từ ad.

**Parameters:**
- `adUnit`: ID của ad unit
- `adSourceName`: Tên ad source
- `revenue`: Giá trị revenue
- `currency`: Đơn vị tiền tệ

## Lưu ý

- Event bus là thread-safe và sử dụng concurrent queue
- Tất cả events được dispatch trên main thread
- Nên unsubscribe khi không cần nữa để tránh memory leaks
- Có thể subscribe nhiều handlers cùng lúc

