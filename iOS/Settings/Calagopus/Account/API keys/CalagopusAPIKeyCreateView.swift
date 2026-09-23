import ScrechKit

struct CalagopusAPIKeyCreateView: View {
    @Environment(CalagopusAPIKeyVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @FocusState private var isFocused
    
    var body: some View {
        List {
            Section {
                TextField("Description", text: $name)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .onSubmit {
                        isFocused = false
                    }
            }
            
            AsyncButton("Create and copy", systemImage: "plus") {
                await vm.create(name) {
                    dismiss()
                }
            }
            .foregroundStyle(name.isEmpty ? Color.secondary : .green)
            .disabled(name.isEmpty)
        }
        .navigationTitle("Create API key")
        .task {
            isFocused = true
        }
    }
}

#Preview {
    CalagopusAPIKeyCreateView()
        .darkSchemePreferred()
        .environment(CalagopusAPIKeyVM())
}
