import SwiftUI

struct BackupListFooter: View {
    private let timeDifference: LocalizedStringResource
    
    init(_ timeDifference: LocalizedStringResource) {
        self.timeDifference = timeDifference
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            
            Text("Latest: \(timeDifference)")
        }
    }
}
