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
                Button {
                    vm.sheetCloudKeys = true
                } label: {
                    Image(systemName: "key.icloud")
                        .frame(40)
                }
            }
            
            Spacer()
            
            Button {
                vm.sheetBrowsePlans = true
            } label: {
                Image(systemName: "externaldrive.badge.plus")
                    .frame(40)
            }
        }
        .buttonBorderShape(.circle)
        .buttonStyle(.glass)
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
