import ScrechKit

struct UploadProgress: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private var quantity: Int
    
    init(_ quantity: Int = 0) {
        self.quantity = quantity
    }
    
    var body: some View {
        VStack {
            Gauge(value: vm.uploadProgress) {
                Text("\(quantity) objects")
                    .subheadline(.bold)
                    .padding(.bottom, 5)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .tint(vm.uploadProgress != 1 ? .blue : .green)
            .multilineTextAlignment(.center)
            .gaugeStyle(.accessoryLinearCapacity)
            
            HStack {
                Text("Uploading to Server •")
                
                Button("Cancel") {
                    vm.cancelUpload()
                }
            }
            .footnote()
        }
    }
}

#Preview {
    List {
        UploadProgress()
    }
    .darkSchemePreferred()
    .environmentObject(FileTabVM(""))
}
