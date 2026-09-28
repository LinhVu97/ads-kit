import Foundation

public class AdTrackingEventBus {
    public static let shared = AdTrackingEventBus()
    
    private var subscribers: [UUID: ([String: Any]) -> Void] = [:]
    private let queue = DispatchQueue(label: "com.fidra.ads.tracking", attributes: .concurrent)
    
    private init() {}
    
    public func subscribe(_ handler: @escaping ([String: Any]) -> Void) -> UUID {
        let id = UUID()
        queue.async(flags: .barrier) {
            self.subscribers[id] = handler
        }
        return id
    }
    
    public func unsubscribe(_ id: UUID) {
        queue.async(flags: .barrier) {
            self.subscribers.removeValue(forKey: id)
        }
    }
    
    public func emit(_ event: [String: Any], completion: (() -> Void)? = nil) {
        queue.async {
            let handlers = self.subscribers.values
            handlers.forEach { handler in
                handler(event)
            }
            if let completion = completion {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    public func removeAllSubscribers() {
        queue.async(flags: .barrier) {
            self.subscribers.removeAll()
        }
    }
}

