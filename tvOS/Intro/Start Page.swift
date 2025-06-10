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
        VStack {
            Text("To activate the app, please enter a valid API-key")
                .title()
            
            HStack(spacing: 32) {
                TextField("API-key", text: $vm.apiKey)
                    .autocorrectionDisabled()
                    .multilineTextAlignment(.center)
                
                SFButton("delete.left") {
                    vm.apiKey = ""
                }
            }
            
            Text("It is recommended to use the keyboard on your iPhone \(Image(systemName: "keyboard.chevron.compact.down"))")
                .title3()
            
            HStack(spacing: 40) {
                ListLink("API-key Creation", icon: "exclamationmark.questionmark") {
                    Guide()
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
                Button("Validate") {
                    Task {
                        await checkApiKey()
                    }
                }
                .disabled(vm.apiKey.isEmpty)
            }
        }
        .navigationTitle("Bisquit.Host")
        .multilineTextAlignment(.center)
        .task {
            if !keys.isEmpty {
                delay(0.5) {
                    vm.sheetCloudKeys = true
                }
            } else {
                print("No keys found")
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
    }
}

#Preview {
    StartPage()
        .environment(NavState())
        .environmentObject(ValueStore())
}
