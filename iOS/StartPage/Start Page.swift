import ScrechKit
import SwiftData

struct StartPage: View {
    @Bindable private var vm = StartPageVM()
    @Environment(NavState.self) private var navState
    @EnvironmentObject private var settings: SettingsStorage
    
    @Environment(\.modelContext) private var modelContext
    @Query(animation: .default) private var keys: [APIKey]
    
    var body: some View {
        VStack {
            Group {
                if vm.showDemo {
                    Button("Demo") {
                        navState.navigate(.toServerList)
                    }
                    .padding()
                    .background(.blue.gradient, in: .capsule)
                    .transition(.movingParts.glare)
                } else {
                    Button("Demo") {}
                        .disabled(true)
                        .opacity(0)
                }
            }
            .title2(.semibold)
            .foregroundStyle(.white)
            .frame(height: 200)
            
            Spacer()
            
            Text("To activate the app, please enter a valid API-key")
                .title(.semibold)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .padding(.horizontal)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            
            HStack {
                TextField("API-key", text: $vm.apiKey)
                    .unbold()
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .cornerRadius(20)
                    .foregroundStyle(.secondary)
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
            
            Spacer()
            
            StartPageFooter()
                .environment(vm)
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .background(Color(0xe3a65e))
        .statusBarHidden()
        .onChange(of: vm.apiKey) { _, newValue in
            if newValue.count == 48 {
                vm.fetchAccountDetails()
            }
        }
        .onReceive(vm.timer) { _ in
            withAnimation {
                vm.showDemo.toggle()
            }
        }
        .onAppear {
            if !keys.isEmpty {
                delay(0.5) {
                    vm.sheetCloudKeys = true
                }
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
            Button("Try again") {}
        } message: {
            Text(vm.errorDescription)
        }
        .sheet($vm.sheetSupport) {
            Support()
        }
        .sheet($vm.sheetBrowsePlans) {
            Browser()
        }
        .sheet($vm.sheetCloudKeys) {
            CloudKeys($vm.apiKey)
        }
    }
}

#Preview {
    StartPage()
        .environment(NavState())
        .environmentObject(SettingsStorage())
}
