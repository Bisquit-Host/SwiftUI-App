import ScrechKit

struct StartPageFooter: View {
    @Environment(StartPageVM.self) private var vm
    
    private let showIcloud: Bool
    
    init(_ showIcloud: Bool = true) {
        self.showIcloud = showIcloud
    }
    
    var body: some View {
        HStack {
            if showIcloud {
                SFButton("key.icloud") {
                    vm.sheetCloudKeys = true
                }
                .padding()
                .background {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .shadow(radius: 8)
                }
            }
            
            Spacer()
            
            SFButton("externaldrive.badge.plus") {
                vm.sheetBrowsePlans = true
            }
            .padding()
            .background {
                Circle()
                    .fill(.ultraThinMaterial)
                    .shadow(radius: 8)
            }
        }
        .title3(.bold)
        .foregroundStyle(.white)
        .padding(.vertical, 32)
        .padding(.horizontal)
    }
}

#Preview {
    StartPageFooter()
        .environment(StartPageVM())
}
