import SwiftUI

struct StartPageFooter: View {
    @Environment(StartPageVM.self) private var vm
    
    private let showIcloud: Bool
    
    init(_ showIcloud: Bool = true) {
        self.showIcloud = showIcloud
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            if showIcloud {
                Button {
                    vm.sheetCloudKeys = true
                } label: {
                    Image(systemName: "key.icloud")
                        .frame(40)
                }
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
        .darkSchemePreferred()
        .environment(StartPageVM())
}
