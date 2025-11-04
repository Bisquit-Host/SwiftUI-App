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
                
                //                HStack(alignment: .top, spacing: 20) {
                FileSection(server.id)
                //                }
                
                //                HStack(alignment: .top, spacing: 20) {
                LogSection(server.id)
                //                }
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("")
        .scrollIndicators(.never)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                SFButton("slider.horizontal.3") {
                    
                }
            }
        }
    }
}
