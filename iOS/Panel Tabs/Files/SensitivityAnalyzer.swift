import SensitiveContentAnalysis
import os

final class SensitivityAnalyzer {
    private let analyzer = SCSensitivityAnalyzer()
    
    func checkImage(_ url: URL, completion: @escaping (Bool) -> Void, onFailure: @escaping () -> Void = {}) async {
        do {
            let handler = try await analyzer.analyzeImage(at: url)
            completion(handler.isSensitive)
        } catch {
            Logger().error("\(error)")
            onFailure()
        }
    }
    
    func checkVideo(_ url: URL, completion: @escaping (Bool) -> Void) async {
        do {
            let handler = analyzer.videoAnalysis(forFileAt: url)
            completion(try await handler.hasSensitiveContent().isSensitive)
        } catch {
            Logger().error("\(error)")
        }
    }
    
    func checkPolicy() -> Bool {
        let policy = analyzer.analysisPolicy
        
        // Analysis is disabled
        if policy == .disabled {
            Logger().info("Analysis is disabled")
            return false
        } else {
            return true
        }
    }
}
