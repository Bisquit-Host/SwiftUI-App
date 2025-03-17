import ScrechKit
import SwiftData

struct StartPage: View {
    @State private var vm = StartPageVM()
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var store: ValueStore
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(animation: .default) private var keys: [APIKey]
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(spacing: 10) {
                    TextField("API-key", text: $vm.apiKey)
                        .secondary()
                        .autocorrectionDisabled()
                        .frame(height: 40)
                        .background(.ultraThinMaterial.opacity(0.2), in: .capsule)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .overlay {
                            Capsule()
                                .stroke(.ultraThinMaterial, lineWidth: 1)
                        }
                        .changeEffect(
                            .shake(rate: .fast),
                            value: vm.trigger
                        )
                    
                    Button("How do I authorize?") {
                        vm.sheetGuide = true
                    }
                    .footnote(.semibold)
                    .foregroundStyle(.white.secondary)
                }
                
                Button {
                    if let string = UIPasteboard.general.string {
                        vm.apiKey = string
                    }
                } label: {
                    Image(systemName: "doc.on.clipboard")
                        .footnote(.bold)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial.opacity(0.2), in: .circle)
                        .overlay {
                            Capsule()
                                .stroke(.ultraThinMaterial, lineWidth: 1)
                        }
                }
                .foregroundStyle(.foreground)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Authorization")
        .frame(maxHeight: .infinity)
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .background {
            Image(.darkBackgroundInfo)
                .resizable()
                .blur(radius: 55)
        }
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
