import ScrechKit
import SwiftData
import Calagopus

struct StartPage: View {
    @Bindable var vm = StartPageVM()
    @EnvironmentObject var store: ValueStore
    @Environment(\.modelContext) var modelContext
    @Query(animation: .default) var keys: [APIKey]
    
    var body: some View {
        ScrollView {
            Text("Using your iPhone, paste the API key from the clipboard")
            
            TextField("API key", text: $vm.apiKey)
                .autocorrectionDisabled()
                .onSubmit {
                    Task {
                        await checkApiKey()
                    }
                }
            
            if vm.apiKey.count == 48 {
                Button("Continue") {
                    Task {
                        await checkApiKey()
                    }
                }
            }
        }
        .sheet($vm.sheetCloudKeys) {
            CloudKeysParent($vm.apiKey)
        }
        .alert(vm.alertTitle, isPresented: $vm.alertInvalid) {
            Button("Try again") {}
        } message: {
            Text(vm.errorDescription)
        }
        .task {
            try? await Task.sleep(for: .seconds(0.5))
            
            if !keys.isEmpty {
                vm.sheetCloudKeys = true
            }
        }
    }
}

#Preview {
    StartPage()
        .darkSchemePreferred()
        .environment(NavState())
        .environmentObject(ValueStore())
}
