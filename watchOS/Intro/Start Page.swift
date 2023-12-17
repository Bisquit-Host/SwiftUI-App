import ScrechKit
import SwiftData

struct StartPage: View {
    @Bindable private var vm = StartPageVM()
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var settings: SettingsStorage
    
    @Environment(\.modelContext) private var modelContext
    @Query(animation: .default) private var keys: [APIKey]
    
    var body: some View {
        ScrollView {
            Text("Using your iPhone, paste the API-key from the clipboard")
            
            TextField("API-key", text: $vm.apiKey)
                .autocorrectionDisabled()
            
            Button("Validate") {
                vm.fetchAccountDetails()
            }
            .title3()
            .disabled(vm.apiKey.isEmpty)
            .foregroundStyle(vm.apiKey.isEmpty ? .secondary : .primary)
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
                
                settings.authSucced()
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
        .environmentObject(SettingsStorage())
}
