import ScrechKit

struct UploadProgress: View {
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
                
                Button("Stop") {
                    
                }
                .disabled(true)
            }
            .footnote()
        }
    }
}

#Preview {
    UploadProgress(0.5)
}
