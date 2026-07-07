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
            
            Button("Create and copy", systemImage: "plus", action: create)
                .foregroundStyle(name.isEmpty ? Color.secondary : .green)
                .disabled(name.isEmpty)
        }
        .navigationTitle("Create API key")
        .task {
            isFocused = true
        }
    }
    
    private func create() {
        Task {
            await vm.create(name) {
                dismiss()
            }
        }
    }
}

#Preview {
    CalagopusAPIKeyCreateView()
        .darkSchemePreferred()
        .environment(CalagopusAPIKeyVM())
}
