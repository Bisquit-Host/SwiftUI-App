import ScrechKit
import SwiftData
import PteroNet

struct StartPage: View {
    @Bindable private var vm = StartPageVM()
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.modelContext) private var modelContext
    @Query(animation: .default) private var keys: [APIKey]
    
    var body: some View {
        ScrollView {
            Text("Using your iPhone, paste the API-key from the clipboard")
            
            TextField("API-key", text: $vm.apiKey)
                .autocorrectionDisabled()
#if DEBUG
            Button("Debug") {
                Keychain.save(key: "selectedApiKey", value: debugKey)
                
                if !keys.contains(where: { $0.key == debugKey }) {
                    modelContext.insert(APIKey(key: debugKey))
                }
                
                store.authSucced()
            }
#endif
        }
        .task {
            try? await Task.sleep(for: .seconds(0.5))
            
            if !keys.isEmpty {
                vm.sheetCloudKeys = true
            }
        }
        .sheet($vm.sheetCloudKeys) {
            CloudKeys($vm.apiKey)
        }
        .onChange(of: vm.apiKey) { _, newValue in
            if newValue.count == 48 {
                vm.fetchAccountDetails()
            }
        }
        .alert("Error \(vm.errorCode)", isPresented: $vm.alertInvalid) {
            Button("Try again") {}
        } message: {
            Text(vm.errorDescription)
        }
        .alert("Is the following information correct?", isPresented: $vm.alertValid) {
            Button("Yes", role: .cancel) {
                if !keys.contains(where: { $0.key == vm.apiKey }) {
                    modelContext.insert(APIKey(key: vm.apiKey))
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
        .environment(NavState())
        .environmentObject(ValueStore())
}
