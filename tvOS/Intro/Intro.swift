import ScrechKit
import SwiftData
import PteroNet

struct Intro: View {
    @Bindable private var vm = StartPageVM()
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.modelContext) private var modelContext
    @Query(animation: .default) private var keys: [APIKey]
    
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
                    Keychain.save(key: "selectedApiKey", value: debugKey)
                    
                    if !keys.contains(where: { $0.key == debugKey }) {
                        modelContext.insert(APIKey(key: debugKey))
                    }
                    
                    store.authSucced()
                }
#endif
                Button("Validate") {
                    vm.fetchAccountDetails()
                }
                .disabled(vm.apiKey.isEmpty)
            }
        }
        .navigationTitle("Bisquit.Host")
        .multilineTextAlignment(.center)
        .onAppear {
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
        .alert("Is the following information correct?", isPresented: $vm.alertValid) {
            Button("Yes", role: .cancel) {
                if !keys.contains(where: { $0.key == vm.apiKey }) {
                    modelContext.insert(APIKey(key: vm.apiKey))
                }
                
                store.authSucced()
            }
            
            Button("No", role: .destructive) {
                vm.accountName.removeAll()
                vm.accountEmail.removeAll()
            }
        } message: {
            Text("Name" + ": \(vm.accountName)\n" + "E-mail" + ": \(vm.accountEmail)")
        }
    }
}

#Preview {
    Intro()
        .environment(NavState())
        .environmentObject(ValueStore())
}
