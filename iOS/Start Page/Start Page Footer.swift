import ScrechKit

struct StartPageFooter: View {
    @Environment(StartPageVM.self) private var vm
    
    var body: some View {
        HStack {
            Button("Need help?") {
                vm.sheetSupport = true
            }
            .padding()
            .background {
                Capsule(.cookie)
                    .shadow(color: .cookie, radius: 8)
            }
            
            Spacer()
            
            SFButton("key.icloud") {
                vm.sheetCloudKeys = true
            }
            .padding()
            .background {
                Circle(.blue)
                    .shadow(color: .blue, radius: 8)
            }
            
            SFButton("externaldrive.badge.plus") {
                vm.sheetBrowsePlans = true
            }
            .padding()
            .background {
                Circle(.cookie)
                    .shadow(color: .cookie, radius: 8)
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
