import ScrechKit

struct UploadProgress: View {
    @EnvironmentObject private var vm: FileTabVM
    
    private var progress: Float
    private var quantity: Int
    
    init(_ progress: Float, quantity: Int = 0) {
        self.progress = progress
        self.quantity = quantity
    }
    
    var body: some View {
        VStack {
            Gauge(value: progress) {
                HStack {
                    Spacer()
                    
                    Text("\(quantity) objects")
                        .subheadline(.bold)
                    
                    Spacer()
                }
                .padding(.bottom, 10)
            }
            .tint(progress != 1 ? .blue : .green)
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
    UploadProgress(0.5)
}
