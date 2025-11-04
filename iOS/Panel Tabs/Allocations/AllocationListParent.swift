import SwiftUI
import PteroNet

struct AllocationListParent: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        NavigationStack {
            AllocationList(server)
        }
        .presentationDragIndicator(.hidden)
        .presentationDetents([.medium, .large])
    }
}
