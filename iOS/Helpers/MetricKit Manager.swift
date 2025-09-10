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
    
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            print("Received metrics:", payload)
        }
    }
    
    func didReceive(_ diagnosticPayloads: [MXDiagnosticPayload]) {
        for payload in diagnosticPayloads {
            print("Received diagnostics:", payload)
        }
    }
}

//extension AppDelegate: MXMetricManagerSubscriber {
//    func didReceive(_ payloads: [MXMetricPayload]) {
//        var output = """
//            Date: \(formattedDate())
//            """
//        for payload in payloads {
//
//            let fileName = "MXMetricPayload_\(formattedDate()).txt"
//
//            if let memoryMetrics = payload.memoryMetrics {
//                output += "\n\nMemory Metrics: \(memoryMetrics.dictionaryRepresentation())"
//            }
//
//            if let cpuMetrics = payload.cpuMetrics {
//                output += "\n\nCPU Metrics: \(cpuMetrics.dictionaryRepresentation())"
//            }
//
//            if let diskIOMetrics = payload.diskIOMetrics {
//                output += "\n\ndiskIO Metrics: \(diskIOMetrics.dictionaryRepresentation())"
//            }
//
//            if let networkTransferMetrics = payload.networkTransferMetrics {
//                output += "\n\nnetworkTransfer Metrics: \(networkTransferMetrics.dictionaryRepresentation())"
//            }
//
//            if let cellularConditionMetrics = payload.cellularConditionMetrics {
//                output += "\n\ncellularCondition Metrics: \(cellularConditionMetrics.dictionaryRepresentation())"
//            }
//
//            if let applicationLaunchMetrics = payload.applicationLaunchMetrics {
//                output += "\n\napplicationLaunch Metrics: \(applicationLaunchMetrics.dictionaryRepresentation())"
//            }
//
//            output += "\n\n\n\nPayload : \(payload.dictionaryRepresentation())"
//            writeUserAccessibleFile(content: "\(output)", fileName: fileName)
//        }
//    }
//
//    func didReceive(_ payloads: [MXDiagnosticPayload]) {
//        for payload in payloads {
//            let jsonString = payload.dictionaryRepresentation()
//            let fileName = "MXDiagnosticPayload_\(formattedDate()).txt"
//            writeUserAccessibleFile(content: "\(jsonString)", fileName: fileName)
//        }
//    }
//}

//extension AppDelegate {
//    private func formattedDate() -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
//
//        return formatter.string(from: Date())
//    }
//
//    func writeUserAccessibleFile(
//        content: String,
//        fileName: String,
//        subdirectoryName: String = "MetricKit Data"
//    ) {
//        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            print("❌ Failed to access documents directory")
//            return
//        }
//
//        let targetDirectory = documentsURL.appendingPathComponent(subdirectoryName)
//
//        do {
//            try FileManager.default.createDirectory(at: targetDirectory, withIntermediateDirectories: true, attributes: nil)
//            let fileURL = targetDirectory.appendingPathComponent(fileName)
//
//            if FileManager.default.fileExists(atPath: fileURL.path) {
//                try FileManager.default.removeItem(at: fileURL)
//                print("️ Deleted existing file:", fileName)
//            }
//
//            try content.write(to: fileURL, atomically: true, encoding: .utf8)
//            print("✅ File saved at:", fileURL.path)
//        } catch {
//            print("❌ Error writing file:", error)
//        }
//    }
//}
