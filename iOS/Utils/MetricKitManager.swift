import Foundation
#if canImport(MetricKit)
import MetricKit
#endif

@Observable
final class MetricKitManager: NSObject, MXMetricManagerSubscriber {
    static let shared = MetricKitManager()
    
    override init() {
        super.init()
        MXMetricManager.shared.add(self)
    }
    
    deinit {
        MXMetricManager.shared.remove(self)
    }
    
    // MetricKit delivers on a background queue; hop to main manually to avoid
    // Swift 6 main-actor precondition crashes.
    nonisolated func didReceive(_ payloads: [MXMetricPayload]) {
        guard shouldSaveMetrics else {
            payloads.forEach {
                print("Received metrics:", $0)
            }
            
            return
        }
        
        for payload in payloads {
            let fileName = "MXMetricPayload_\(formattedDate()).txt"
            var output = """
                Date: \(formattedDate())
                """
            
            if let memoryMetrics = payload.memoryMetrics {
                output += "\n\nMemory Metrics: \(memoryMetrics.dictionaryRepresentation())"
            }
            
            if let cpuMetrics = payload.cpuMetrics {
                output += "\n\nCPU Metrics: \(cpuMetrics.dictionaryRepresentation())"
            }
            
            if let diskIOMetrics = payload.diskIOMetrics {
                output += "\n\ndiskIO Metrics: \(diskIOMetrics.dictionaryRepresentation())"
            }
            
            if let networkTransferMetrics = payload.networkTransferMetrics {
                output += "\n\nnetworkTransfer Metrics: \(networkTransferMetrics.dictionaryRepresentation())"
            }
            
            if let cellularConditionMetrics = payload.cellularConditionMetrics {
                output += "\n\ncellularCondition Metrics: \(cellularConditionMetrics.dictionaryRepresentation())"
            }
            
            if let applicationLaunchMetrics = payload.applicationLaunchMetrics {
                output += "\n\napplicationLaunch Metrics: \(applicationLaunchMetrics.dictionaryRepresentation())"
            }
            
            output += "\n\n\n\nPayload : \(payload.dictionaryRepresentation())"
            writeMetricsFile(content: output, fileName: fileName)
        }
    }
    
    nonisolated func didReceive(_ diagnosticPayloads: [MXDiagnosticPayload]) {
        guard shouldSaveMetrics else {
            diagnosticPayloads.forEach {
                print("Received diagnostics:", $0)
            }
            
            return
        }
        
        for payload in diagnosticPayloads {
            let jsonString = payload.dictionaryRepresentation()
            let fileName = "MXDiagnosticPayload_\(formattedDate()).txt"
            
            writeMetricsFile(content: "\(jsonString)", fileName: fileName)
        }
    }
    
    nonisolated var shouldSaveMetrics: Bool {
        let saveMetrics = UserDefaults.standard.bool(forKey: "saveMetrics")
        
        if saveMetrics {
            print("Metrics are enabled")
        }
        
        return saveMetrics
    }
    
    nonisolated func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter.string(from: Date())
    }
    
    nonisolated func writeMetricsFile(content: String, fileName: String, subdirectoryName: String = "Metrics") {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Failed to access documents directory")
            return
        }
        
        let targetDirectory = documentsURL.appendingPathComponent(subdirectoryName)
        
        do {
            try FileManager.default.createDirectory(at: targetDirectory, withIntermediateDirectories: true, attributes: nil)
            let fileURL = targetDirectory.appendingPathComponent(fileName)
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
                print("️ Deleted existing file:", fileName)
            }
            
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            print("✅ Metrics file saved at:", fileURL.path)
        } catch {
            print("❌ Error writing metrics file:", error)
        }
    }
}
