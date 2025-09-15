import ScrechKit
import PteroNet

struct DashboardView: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                DashboardViewHeader(server)
                
                StatRows(server)
                
                HStack(alignment: .top, spacing: 20) {
                    FileSection()
                    
                    PerformanceCard()
                }
                
                LogSection(server.id)
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
//            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    AvatarStack()
                    
                    SFButton("slider.horizontal.3") {
                        
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.controlBackgroundColor))
    }
}
