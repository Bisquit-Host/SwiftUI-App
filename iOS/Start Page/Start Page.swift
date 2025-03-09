import ScrechKit
import SwiftData

struct StartPage: View {
    @State private var vm = StartPageVM()
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.modelContext) private var modelContext
    @Query(animation: .default) private var keys: [APIKey]
    
    var body: some View {
        VStack {
            Text("To activate the app, please enter a valid API-key")
                .title(.semibold)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .padding(.horizontal)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            
            HStack {
                TextField("API-key", text: $vm.apiKey)
                    .secondary()
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .cornerRadius(20)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .changeEffect(
                        .shake(rate: .fast),
                        value: vm.trigger
                    )
                
                SFButton("doc.on.clipboard") {
                    if let string = UIPasteboard.general.string {
                        vm.apiKey = string
                    }
                }
                .foregroundStyle(.white)
            }
            .padding(10)
            
            Button("Where to find the API-key?") {
                vm.sheetGuide = true
            }
            .footnote(.semibold)
            .foregroundStyle(.white.secondary)
        }
        .frame(maxHeight: .infinity)
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .background(Color(0xe3a65e))
        .statusBarHidden()
        .overlay(alignment: .bottom) {
            StartPageFooter(keys.count > 0)
                .environment(vm)
        }
        .onChange(of: vm.apiKey) { _, newValue in
            if newValue.count == 48 || newValue.count == 340 {
                vm.fetchAccountDetails()
            }
        }
        .task {
            if !keys.isEmpty {
                delay(0.5) {
                    vm.sheetCloudKeys = true
                }
            }
        }
        .alert("Is the following information correct?", isPresented: $vm.alertValid) {
            Button("Yes", role: .cancel) {
                if !keys.contains(where: { $0.key == vm.apiKey }) {
                    modelContext.insert(APIKey("", key: vm.apiKey))
                }
                
                store.authSucced()
            }
            
            Button("No", role: .destructive) {
                vm.accountName = ""
                vm.accountEmail = ""
            }
        } message: {
            Text("Name: \(vm.accountName)\nE-mail: \(vm.accountEmail)")
        }
        .alert("Error \(vm.errorCode)", isPresented: $vm.alertInvalid) {
            Button("Try again") {
                vm.fetchAccountDetails()
            }
            
            Button("Remove this key", role: .destructive) {
                let key = keys.first {
                    $0.key == vm.apiKey
                }
                
                if let key {
                    modelContext.delete(key)
                }
                
                vm.apiKey = ""
            }
        } message: {
            Text(vm.errorDescription)
        }
        .sheet($vm.sheetGuide) {
            Guide()
        }
        .sheet($vm.sheetBrowsePlans) {
            BrowserParent()
        }
        .sheet($vm.sheetCloudKeys) {
            CloudKeys($vm.apiKey)
        }
    }
}

#Preview {
    StartPage()
        .environment(NavState())
        .environmentObject(ValueStore())
}
