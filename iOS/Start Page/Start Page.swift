import ScrechKit
import SwiftData

struct StartPage: View {
    @State var vm = StartPageVM()
    @Environment(NavState.self) private var navState
    @EnvironmentObject var store: ValueStore
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var modelContext
    @Query(animation: .default) var keys: [APIKey]
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(spacing: 10) {
                    TextField("API-key", text: $vm.apiKey)
                        .secondary()
                        .autocorrectionDisabled()
                        .frame(height: 40)
                        .background(.ultraThickMaterial.opacity(0.2), in: .capsule)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .overlay {
                            Capsule()
                                .stroke(.ultraThinMaterial, lineWidth: 1)
                        }
                        .changeEffect(.shake(rate: .fast), value: vm.trigger)
                    
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
            BackgroundImage()
        }
        .statusBarHidden()
        .overlay(alignment: .bottom) {
            StartPageFooter(keys.count > 0)
                .environment(vm)
        }
        .onChange(of: vm.apiKey) { _, newValue in
            if newValue.count == 48 || newValue.count == 340 {
                checkApiKey()
            }
        }
        .task {
            if !keys.isEmpty {
                delay(0.5) {
                    vm.sheetCloudKeys = true
                }
            }
        }
        .alert("Error \(vm.errorCode)", isPresented: $vm.alertInvalid) {
            Button("Try again") {
                checkApiKey()
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
    NavigationView {
        StartPage()
    }
    .environment(NavState())
    .environmentObject(ValueStore())
}
