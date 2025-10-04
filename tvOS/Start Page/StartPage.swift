import ScrechKit
import SwiftData
import PteroNet

struct StartPage: View {
    @Bindable var vm = StartPageVM()
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
            
            let icon = Image(systemName: "keyboard.chevron.compact.down")
            
            Text("It is recommended to use the keyboard on your iPhone \(icon)")
                .title3()
            
            HStack {
                ListLink("API-key Creation", icon: "exclamationmark.questionmark") {
                    Guide()
                }
                
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
        .sheet($vm.sheetCloudKeys) {
            CloudKeysParent($vm.apiKey)
        }
        .alert("Error \(vm.errorCode)", isPresented: $vm.alertInvalid) {
            Button("Try again") {}
        } message: {
            Text(vm.errorDescription)
        }
        .onFirstAppear {
            if !keys.isEmpty {
                delay(0.5) {
                    vm.sheetCloudKeys = true
                }
            } else {
                print("No keys found")
            }
        }
    }
}

#Preview {
    NavigationStack {
        StartPage()
    }
    .darkSchemePreferred()
    .environment(NavState())
}
