import ScrechKit
import SwiftData

struct StartPage: View {
    @Bindable var vm = StartPageVM()
    @EnvironmentObject var store: ValueStore
    
    @Environment(\.modelContext) var modelContext
    @Query(animation: .default) var keys: [APIKey]
    
    var body: some View {
        VStack {
            NavigationLink("How do I authorize?") {
                Guide()
                    .frame(width: 300, height: 600)
            }
            
            HStack {
                TextField("API-key", text: $vm.apiKey)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 600)
                
                Button {
#if os(macOS)
                    if let string = NSPasteboard.general.string(forType: .string) {
                        vm.apiKey = string
                    }
#else
                    if let string = UIPasteboard.general.string {
                        vm.apiKey = string
                    }
#endif
                } label: {
                    Image(systemName: "doc.on.clipboard")
                        .frame(height: 25)
                }
            }
            .padding(.horizontal)
            
            ForEach(keys) { key in
                Button {
                    vm.apiKey = key.key
                    
                    if !keys.contains(where: { $0.key == vm.apiKey }) {
                        modelContext.insert(APIKey("", key: vm.apiKey))
                    }
                    
                    store.authSucced()
                } label: {
                    VStack(alignment: .leading) {
                        Text(key.name)
                        
                        Text(key.key.prefix(10))
                            .footnote()
                            .secondary()
                    }
                }
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(0.5))
            
            if !keys.isEmpty {
                vm.sheetCloudKeys = true
            }
        }
        .alert("Error \(vm.errorCode)", isPresented: $vm.alertInvalid) {
            Button("Try again") {
                
            }
        } message: {
            Text(vm.errorDescription)
        }
        .onChange(of: vm.apiKey) { _, newValue in
            if newValue.count == 48 {
                Task {
                    await checkApiKey()
                }
            }
        }
        //        .sheet($vm.sheetSupport) {
        //            Support()
        //        }
        //        .sheet($vm.sheetBrowsePlans) {
        //            PlanListParent()
        //        }
        //        .sheet($vm.sheetCloudKeys) {
        //            CloudKeys($vm.apiKey)
        //                .frame(width: 400)
        //        }
    }
}

#Preview {
    StartPage()
        .padding()
        .environmentObject(ValueStore())
}
