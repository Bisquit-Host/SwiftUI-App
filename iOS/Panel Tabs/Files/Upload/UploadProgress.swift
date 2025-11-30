import ScrechKit

struct UploadProgress: View {
    @EnvironmentObject private var vm: FileTabVM
    
    var body: some View {
        VStack {
            if vm.uploadProgress != 0 {
                Gauge(value: vm.uploadProgress) {
                    Text("\(vm.uploadingCount) objects")
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
}

#Preview {
    List {
        UploadProgress()
    }
    .darkSchemePreferred()
    .environmentObject(FileTabVM(""))
}
