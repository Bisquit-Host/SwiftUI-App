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
                HStack {
                    Spacer()
                    
                    Text("\(quantity) objects")
                        .subheadline(.bold)
                    
                    Spacer()
                }
                .padding(.bottom, 5)
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
    .environmentObject(FileTabVM(""))
}
