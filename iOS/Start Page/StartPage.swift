import ScrechKit
import SwiftData

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
                    TextField("API-key", text: $vm.apiKey)
                        .secondary()
                        .autocorrectionDisabled()
                        .frame(height: 40)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .glassEffect()
                        .changeEffect(.shake(rate: .fast), value: vm.trigger)
                        .focused($isFocused)
                    
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
        .navigationBarBackButtonHidden()
        .background {
            BackgroundImage()
        }
        .onChange(of: vm.apiKey) { _, newValue in
            if newValue.count == 48 || newValue.count == 340 {
                Task {
                    await checkApiKey()
                }
            }
        }
        .task {
            Task {
                if !keys.isEmpty {
                    try await Task.sleep(for: .seconds(0.5))
                    
                    vm.sheetCloudKeys = true
                }
            }
        }
        .alert("Error \(vm.errorCode)", isPresented: $vm.alertInvalid) {
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
