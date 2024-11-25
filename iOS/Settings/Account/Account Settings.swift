import SwiftUI

struct AccountSettings: View {
    @State private var vm = ApikeyVM()
    @EnvironmentObject private var settings: ValueStorage
    
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
        }
        .foregroundStyle(.primary)
        .listRowBackground(settings.transparentList ? .clear : Color.list)
        .task {
            vm.fetchKeys()
        }
        .sheet($sheetApiKeys) {
            ApikeyList()
                .environment(vm)
        }
    }
}

#Preview {
    List {
        AccountSettings()
    }
    .environmentObject(ValueStorage())
}
