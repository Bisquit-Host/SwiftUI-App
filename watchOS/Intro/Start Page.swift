import ScrechKit
import SwiftData
import PteroNet

struct StartPage: View {
    @Bindable var vm = StartPageVM()
    @Environment(NavState.self) private var navState
    @EnvironmentObject var store: ValueStore
    
    @Environment(\.modelContext) var modelContext
    @Query(animation: .default) var keys: [APIKey]
    
    var body: some View {
        ScrollView {
            Text("Using your iPhone, paste the API-key from the clipboard")
            
            TextField("API-key", text: $vm.apiKey)
                .autocorrectionDisabled()
            
            if vm.apiKey.count == 48 {
                Button("Continue") {
                    checkApiKey()
                }
            }
#if DEBUG
            Button("Debug") {
                Keychain.save(debugKey, forKey: "selectedApiKey")
                
                if !keys.contains(where: { $0.key == debugKey }) {
                    modelContext.insert(APIKey("Debug", key: debugKey))
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
                checkApiKey()
            }
        }
        .alert("Error \(vm.errorCode)", isPresented: $vm.alertInvalid) {
            Button("Try again") {}
        } message: {
            Text(vm.errorDescription)
        }
    }
}

#Preview {
    StartPage()
        .environment(NavState())
        .environmentObject(ValueStore())
}
