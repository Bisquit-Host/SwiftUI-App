import ScrechKit

struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                DashboardViewHeader()
                
                StatRows()
                
                HStack(alignment: .top, spacing: 20) {
                    FileSection()
                    
                    PerformanceCard()
                }
                
                ProjectCard()
            }
            .padding(24)
        }
        .navigationTitle("Server name")
        .navigationSubtitle("Server description")
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
