import SwiftUI

struct AccountSettings: View {
    @State private var vm = ApikeyVM()
    
    @State private var sheetApiKeys = false
    
    var body: some View {
        Section("Account") {
            CredentialsButton()
            
            Button {
                sheetApiKeys = true
            } label: {
                HStack {
                    Text("My API-keys")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.forward")
                        .secondary()
                }
            }
            .foregroundStyle(.primary)
            .sheet($sheetApiKeys) {
                NavigationView {
                    ApikeyList()
                }
                .environment(vm)
            }
        }
        .transparentSection()
        .task {
            vm.fetchKeys()
        }
    }
}

#Preview {
    List {
        AccountSettings()
    }
    .environmentObject(ValueStore())
}
