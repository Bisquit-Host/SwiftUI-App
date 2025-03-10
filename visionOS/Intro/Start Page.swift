import ScrechKit
import PteroNet
import SwiftData

struct StartPage: View {
    @Bindable private var vm = StartPageVM()
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.modelContext) private var modelContext
    @Query(animation: .default) private var keys: [APIKey]
    
    var body: some View {
        VStack {
            HStack {
                TextField("API-key", text: $vm.apiKey)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 600)
                
                SFButton("doc.on.clipboard") {
                    if let string = UIPasteboard.general.string {
                        vm.apiKey = string
                    }
                }
                .foregroundStyle(.white)
            }
            .padding(10)
            
            NavigationLink("API-key Creation") {
                Guide()
            }
            
            Button("Confirm") {
                vm.fetchAccountDetails()
            }
            .title()
            .padding()
            .disabled(vm.apiKey.isEmpty)
        }
        .task {
            if !keys.isEmpty {
                try? await Task.sleep(for: .seconds(0.5))
                
                vm.sheetCloudKeys = true
            }
        }
        .sheet($vm.sheetCloudKeys) {
            CloudKeys($vm.apiKey)
        }
        .alert("Error \(vm.errorCode)", isPresented: $vm.alertInvalid) {
            Button("Try again") {}
        } message: {
            Text(vm.errorDescription)
        }
        .toolbar {
            Button("Debug") {
                Keychain.save(key: "selectedApiKey", value: debugKey)
                
                if !keys.contains(where: { $0.key == debugKey }) {
                    modelContext.insert(APIKey("Debug", key: debugKey))
                }
                
                store.authSucced()
            }
        }
        .alert("Is the following information correct?", isPresented: $vm.alertValid) {
            Button("Yes", role: .cancel) {
                if !keys.contains(where: { $0.key == vm.apiKey }) {
                    modelContext.insert(APIKey("", key: vm.apiKey))
                }
                
                store.authSucced()
            }
            
            Button("No", role: .destructive) {
                vm.accountName = ""
                vm.accountEmail = ""
            }
        } message: {
            Text("Name: \(vm.accountName)\nE-mail: \(vm.accountEmail)")
        }
    }
}

#Preview {
    StartPage()
        .padding()
        .glassBackgroundEffect()
        .environment(NavState())
        .environmentObject(ValueStore())
}
