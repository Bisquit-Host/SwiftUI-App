import Foundation

#if os(iOS) && canImport(UIKit)
import OSLog
import PteroNet
import UIKit

#if canImport(DeviceKit)
import DeviceKit
#endif

@MainActor
enum PushTokenService {
    private static let logger = Logger(subsystem: "host.bisquit.Bisquit-host", category: "PushToken")
    private static let deviceIdKey = "push_device_id"
    private static let pushTokenURL = URL(string: "https://test-api.bisquit.host/push-token")
    private static let pushTokenInvalidateURL = URL(string: "https://test-api.bisquit.host/push-token/invalidate")
    
    private struct PushTokenRequest: Encodable {
        let deviceId: String
        let meta: [String: String]
        let type: String
        let pushToken: String
    }
    
    private struct PushTokenInvalidateRequest: Encodable {
        let deviceId: String
    }
    
    static func sendIfPossible(accessToken: String?, pushToken: String?) async {
        guard let accessToken, !accessToken.isEmpty else { return }
        guard let pushToken, !pushToken.isEmpty else { return }
        
        let request = PushTokenRequest(
            deviceId: deviceId(),
            meta: pushTokenMeta(),
            type: "apns",
            pushToken: pushToken
        )
        
        if !(await registerPushToken(accessToken: accessToken, request: request)) {
            logger.error("Push token registration failed")
        }
    }
    
    static func invalidateIfPossible(accessToken: String?) async {
        guard let accessToken, !accessToken.isEmpty else { return }
        
        let request = PushTokenInvalidateRequest(deviceId: deviceId())
        
        if !(await invalidatePushToken(accessToken: accessToken, request: request)) {
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
#if canImport(DeviceKit)
        String(describing: Device.current)
#else
        UIDevice.current.name
#endif
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
    
    private static func registerPushToken(accessToken: String, request: PushTokenRequest) async -> Bool {
        guard let url = pushTokenURL else { return false }
        return await sendPushTokenRequest(url: url, accessToken: accessToken, request: request)
    }
    
    private static func invalidatePushToken(accessToken: String, request: PushTokenInvalidateRequest) async -> Bool {
        guard let url = pushTokenInvalidateURL else { return false }
        return await sendPushTokenRequest(url: url, accessToken: accessToken, request: request)
    }
    
    private static func sendPushTokenRequest<T: Encodable>(url: URL, accessToken: String, request: T) async -> Bool {
        guard let body = try? JSONEncoder().encode(request) else {
            logger.error("Push token request encoding failed")
            return false
        }
        
        if let bodyString = String(data: body, encoding: .utf8) {
            logger.info("Push token payload: \(bodyString)")
        } else {
            logger.warning("Push token payload encoding to string failed")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = body
        
        do {
            let (_, response) = try await URLSession.shared.data(for: urlRequest)
            guard let http = response as? HTTPURLResponse else { return false }
            logger.info("Response: \(http.statusCode)")
            return (200...299).contains(http.statusCode)
        } catch {
            logger.error("Push token request failed: \(error)")
            return false
        }
    }
}
#else
enum PushTokenService {
    static func sendIfPossible(accessToken: String?, pushToken: String?) async {}
    static func invalidateIfPossible(accessToken: String?) async {}
}
#endif
