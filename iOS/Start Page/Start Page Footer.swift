import ScrechKit

struct StartPageFooter: View {
    @Environment(StartPageVM.self) private var vm
    
    var body: some View {
        HStack {
            SFButton("key.icloud") {
                vm.sheetCloudKeys = true
            }
            .padding()
            .background {
                Circle()
                    .fill(.blue.gradient)
                    .shadow(radius: 8)
            }
            
            Spacer()
            
            SFButton("externaldrive.badge.plus") {
                vm.sheetBrowsePlans = true
            }
            .padding()
            .background {
                Circle()
                    .fill(.cookie.gradient)
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
