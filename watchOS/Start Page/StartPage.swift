import ScrechKit
import SwiftData
import PteroNet

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
        .alert("Error \(vm.errorCode)", isPresented: $vm.alertInvalid) {
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
        .onChange(of: vm.apiKey) { _, newValue in
            if newValue.count == 48 {
                Task {
                    await checkApiKey()
                }
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
