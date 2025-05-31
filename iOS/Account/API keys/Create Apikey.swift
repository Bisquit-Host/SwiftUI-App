import ScrechKit

struct CreateApikey: View {
    @Environment(ApikeyVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var text = ""
    @FocusState private var focus
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Description", text: $text)
                        .autocorrectionDisabled()
                        .focused($focus)
                        .onSubmit {
                            focus = false
                        }
                }
                .transparentSection()
                
                Button {
                    Task {
                        await vm.create(text) {
                            dismiss()
                        }
                    }
                } label: {
                    HStack {
                        Text("Create and copy")
                        
                        Spacer()
                        
                        Image(systemName: "plus")
                    }
                    .foregroundStyle(text.isEmpty ? Color.secondary : .green)
                }
                .disabled(text.isEmpty)
                .transparentSection()
            }
            .navigationTitle("Create API-key")
            .navigationBarTitleDisplayMode(.inline)
            .transparentList()
        }
        .task {
            focus = true
        }
    }
}

#Preview {
    CreateApikey()
        .environment(ApikeyVM())
}
