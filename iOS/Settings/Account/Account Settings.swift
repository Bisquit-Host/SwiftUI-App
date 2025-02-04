import SwiftUI

struct AccountSettings: View {
    @State private var vm = ApikeyVM()
    @EnvironmentObject private var store: ValueStore
    
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
                ApikeyList()
                    .environment(vm)
            }
        }
        .listRowBackground(store.transparentList ? .clear : Color.list)
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
