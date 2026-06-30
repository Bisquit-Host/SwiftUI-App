import SwiftUI
import Calagopus

struct ArchiveFormatSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    private let fileName: String
    private let onCreate: (String, CalagopusFileArchiveFormat) -> Void
    
    @State private var archiveName = ""
    @State private var format: CalagopusFileArchiveFormat = .tarGz
    
    init(fileName: String, onCreate: @escaping (String, CalagopusFileArchiveFormat) -> Void) {
        self.fileName = fileName
        self.onCreate = onCreate
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Archive name") {
                    TextField(createdName, text: $archiveName)
                        .autocorrectionDisabled()
                }
                
                Picker("Format", selection: $format) {
                    ForEach(CalagopusFileArchiveFormat.allCases, id: \.self) {
                        Text($0.title)
                            .tag($0)
                    }
                }
            }
            .navigationTitle("Create Archive")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark", action: dismiss.callAsFunction)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create", systemImage: "archivebox", action: create)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private var createdName: String {
        if archiveName.isEmpty {
            generatedArchiveName
        } else {
            archiveName + format.title
        }
    }
    
    private var generatedArchiveName: String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        let secondsFromGMT = TimeZone.current.secondsFromGMT(for: now)
        let timezoneSign = secondsFromGMT < 0 ? "-" : "+"
        let timezone = abs(secondsFromGMT)
        let timezoneHours = timezone / 3600
        let timezoneMinutes = timezone % 3600 / 60
        
        return "archive-\(components.year ?? 0)-\(twoDigits(components.month))-\(twoDigits(components.day))T\(twoDigits(components.hour))\(twoDigits(components.minute))\(twoDigits(components.second))\(timezoneSign)\(twoDigits(timezoneHours))\(twoDigits(timezoneMinutes))\(format.title)"
    }
    
    private func twoDigits(_ value: Int?) -> String {
        (value ?? 0).formatted(.number.precision(.integerLength(2)))
    }
    
    private func create() {
        onCreate(createdName, format)
        dismiss()
    }
}

private extension CalagopusFileArchiveFormat {
    var title: String {
        switch self {
        case .tar: ".tar"
        case .tarGz: ".tar.gz"
        case .tarXz: ".tar.xz"
        case .tarLzip: ".tar.lz"
        case .tarBz2: ".tar.bz2"
        case .tarLz4: ".tar.lz4"
        case .tarZstd: ".tar.zst"
        case .zip: ".zip"
        case .sevenZip: ".7z"
        }
    }
}

#Preview {
    ArchiveFormatSheet(fileName: "world") { _, _ in }
}
