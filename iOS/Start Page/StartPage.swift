import ScrechKit
import SwiftData
import Calagopus

struct StartPage: View {
    @State var vm = StartPageVM()
    @EnvironmentObject var store: ValueStore
    @Environment(\.modelContext) var modelContext
    @Query(animation: .default) var keys: [APIKey]
    
    @FocusState private var isFocused
    
    var body: some View {
        ZStack {
            HStack(alignment: .top) {
                VStack(spacing: 16) {
                    StartPageAPIKeyField($isFocused)
                        .environment(vm)
                        .onSubmit {
                            Task {
                                await checkApiKey()
                            }
                        }
                    
                    Button("How do I authorize?") {
                        vm.sheetGuide = true
                    }
                    .footnote(.semibold)
                    .foregroundStyle(.white.secondary)
                }
                
                Button(action: pasteAPIKey) {
                    Image(systemName: "doc.on.clipboard")
                        .footnote(.bold)
                        .frame(40)
                }
                .glassEffect()
                .foregroundStyle(.foreground)
            }
            .padding(.horizontal)
            .frame(maxHeight: .infinity)
            
            StartPageFooter(keys.count > 0)
                .environment(vm)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .navigationTitle("Authorization")
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxHeight: .infinity)
        .ignoresSafeArea()
        .background {
            BackgroundImage()
        }
        .task {
            await checkIfKeysExist()
        }
        .alert(vm.alertTitle, isPresented: $vm.alertInvalid) {
            Button("Try again", role: .confirm, action: retry)
            Button("Remove this key", role: .destructive, action: removeSelectedKey)
        } message: {
            Text(vm.errorDescription)
        }
        .sheet($vm.sheetGuide) {
            Guide()
        }
        .sheet($vm.sheetCloudKeys) {
            CloudKeysParent($vm.apiKey)
        }
    }
    
    private func checkIfKeysExist() async {
        if !keys.isEmpty {
            try? await Task.sleep(for: .seconds(0.5))

            vm.sheetCloudKeys = true
        }
    }
    
    private func retry() {
        Task {
            await checkApiKey()
        }
    }
    
    private func pasteAPIKey() {
        isFocused = false
        
        if let string = UIPasteboard.general.string {
            vm.apiKey = string
        }
    }
    
    private func removeSelectedKey() {
        let key = keys.first {
            $0.key == vm.apiKey
        }
        
        if let key {
            if Keychain.load(key: "selectedApiKey") == key.key {
                Keychain.delete(key: "selectedApiKey")
                store.isApiKeyValid = false
            }
            
            modelContext.delete(key)
        }
        
        vm.apiKey = ""
    }
}

#Preview {
    NavigationStack {
        StartPage()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
