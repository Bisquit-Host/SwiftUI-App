import ScrechKit
import PteroNet
import SwiftData

struct StartPage: View {
    @Bindable var vm = StartPageVM()
    @EnvironmentObject var store: ValueStore
    @Environment(\.modelContext) var modelContext
    @Query(animation: .default) var keys: [APIKey]
    
    var body: some View {
        VStack {
            HStack {
                TextField("API-key", text: $vm.apiKey)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 600)
                
                SFButton("doc.on.clipboard") {
                    pasteApiKey()
                }
                .foregroundStyle(.white)
            }
            .padding(10)
            
            NavigationLink("API-key Creation") {
                Guide()
            }
            
            Button("Confirm") {
                Task {
                    await checkApiKey()
                }
            }
            .title()
            .padding()
            .disabled(vm.apiKey.isEmpty)
        }
        .sheet($vm.sheetCloudKeys) {
            CloudKeysParent($vm.apiKey)
        }
        .task {
            if !keys.isEmpty {
                try? await Task.sleep(for: .seconds(0.5))
                
                vm.sheetCloudKeys = true
            }
        }
        .alert("Error \(vm.errorCode)", isPresented: $vm.alertInvalid) {
            Button("Try again") {}
        } message: {
            Text(vm.errorDescription)
        }
    }
    
    private func pasteApiKey() {
        if let string = UIPasteboard.general.string {
            vm.apiKey = string
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
