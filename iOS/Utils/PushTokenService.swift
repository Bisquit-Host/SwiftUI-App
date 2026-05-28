import SwiftUI

#if os(iOS)
import BisquitoNet
import OSLog
import PteroNet
import DeviceKit

enum PushTokenService {
    private static let logger = Logger(subsystem: "host.bisquit.Bisquit-host", category: "PushTokenService")
    private static let deviceIdKey = "push_device_id"
    
    static func sendIfPossible(accessToken: String, pushToken: String?) async {
        guard let pushToken, !pushToken.isEmpty else { return }
        
        let request = PushTokenRequest(
            deviceId: deviceId(),
            meta: pushTokenMeta(),
            type: "apple",
            pushToken: pushToken
        )
        
        Logger().info("Push token meta: \(pushTokenMeta())")
        
        if !(await pushTokenRegisterAPI(accessToken: accessToken, request: request)) {
            logger.error("Push token registration failed")
        }
    }
    
    static func invalidateIfPossible() async {
        guard let accessToken = accessToken() else { return }
        
        let request = PushTokenInvalidateRequest(deviceId: deviceId())
        
        if !(await pushTokenInvalidateAPI(accessToken: accessToken, request: request)) {
            logger.error("Push token invalidation failed")
        }
    }
    
    private static func deviceId() -> String {
        if let cached = Keychain.load(key: deviceIdKey), !cached.isEmpty {
            return cached
        }
        
        let newID = UUID().uuidString
        _ = Keychain.save(newID, forKey: deviceIdKey)
        
        return newID
    }
    
    private static func pushTokenMeta() -> [String: String] {
        var meta: [String: String] = [:]
        
        meta["device_name"] = deviceName()
        meta["system_version"] = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        meta["app_version"] = appVersion()
        meta["system_appearance"] = systemAppearance()
        meta["system_lang"] = Locale.preferredLanguages.first ?? Locale.current.identifier
        meta["low_power_mode"] = ProcessInfo.processInfo.isLowPowerModeEnabled ? "true" : "false"
        meta["thermal_state"] = thermalState()
        
        let storage = storageMetrics()
        meta["used_storage"] = storage.used
        meta["total_storage"] = storage.total
        meta["reduce_motion"] = UIAccessibility.isReduceMotionEnabled ? "true" : "false"
        meta["differentiate_without_color"] = UIAccessibility.shouldDifferentiateWithoutColor ? "true" : "false"
        
        return meta
    }
    
    private static func appVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        if let version, let build, !build.isEmpty, version != build {
            return "\(version) (\(build))"
        }
        
        return version ?? build ?? "unknown"
    }
    
    private static func deviceName() -> String {
        String(describing: Device.current.description)
    }
    
    private static func systemAppearance() -> String {
        switch currentUserInterfaceStyle() {
        case .light: "light"
        case .dark: "dark"
        default: "unspecified"
        }
    }
    
    private static func currentUserInterfaceStyle() -> UIUserInterfaceStyle {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let window = scenes.flatMap(\.windows).first { $0.isKeyWindow }
        return window?.traitCollection.userInterfaceStyle ?? .unspecified
    }
    
    private static func thermalState() -> String {
        switch ProcessInfo.processInfo.thermalState {
        case .nominal: "nominal"
        case .fair: "fair"
        case .serious: "serious"
        case .critical: "critical"
        @unknown default: "unknown"
        }
    }
    
    private static func storageMetrics() -> (used: String, total: String) {
        do {
            let values = try URL(fileURLWithPath: NSHomeDirectory())
                .resourceValues(forKeys: [
                    .volumeTotalCapacityKey,
                    .volumeAvailableCapacityForImportantUsageKey,
                    .volumeAvailableCapacityKey
                ])
            
            let total = Int64(values.volumeTotalCapacity ?? 0)
            let available: Int64
            
            if let important = values.volumeAvailableCapacityForImportantUsage {
                available = Int64(important)
            } else if let regular = values.volumeAvailableCapacity {
                available = Int64(regular)
            } else {
                available = 0
            }
            
            let used = max(total - available, 0)
            return (String(used), String(total))
        } catch {
            logger.error("Storage metrics error: \(error)")
            return ("0", "0")
        }
    }
}
#else
enum PushTokenService {
    static func sendIfPossible(accessToken: String, pushToken: String?) async {}
    static func invalidateIfPossible() async {}
}
#endif
