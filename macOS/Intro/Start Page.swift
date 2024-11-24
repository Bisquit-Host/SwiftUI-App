import ScrechKit
import SwiftData

struct StartPage: View {
    @Bindable private var vm = StartPageVM()
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var settings: ValueStorage
    
    @Environment(\.modelContext) private var modelContext
    @Query(animation: .default) private var keys: [APIKey]
    
    var body: some View {
        VStack {
            NavigationLink("How to obtain an API-key") {
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
                        modelContext.insert(APIKey(key: vm.apiKey))
                    }
                    
                    settings.authSucced()
                } label: {
                    Text(key.key.prefix(10))
                }
            }
            
            //            Button("Key list") {
            //                vm.sheetCloudKeys = true
            //            }
        }
        .task {
            try? await Task.sleep(for: .seconds(0.5))
            
            if !keys.isEmpty {
                vm.sheetCloudKeys = true
            }
        }
        .alert("Is the following information correct?", isPresented: $vm.alertValid) {
            Button("Yes", role: .cancel) {
                if !keys.contains(where: { $0.key == vm.apiKey }) {
                    modelContext.insert(APIKey(key: vm.apiKey))
                }
                
                settings.authSucced()
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
                
            }
        } message: {
            Text(vm.errorDescription)
        }
        .onChange(of: vm.apiKey) { _, newValue in
            if newValue.count == 48 {
                vm.fetchAccountDetails()
            }
        }
        //        .sheet($vm.sheetSupport) {
        //        Support()
        //    }
        //        .sheet($vm.sheetBrowsePlans) {
        //        Browser()
        //    }
        //        .sheet($vm.sheetCloudKeys) {
        //            CloudKeys($vm.apiKey)
        //                .frame(width: 400)
        //        }
    }
}

#Preview {
    StartPage()
        .padding()
        .environment(NavState())
        .environmentObject(ValueStorage())
}
