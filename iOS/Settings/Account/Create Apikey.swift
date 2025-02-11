import ScrechKit

struct CreateApikey: View {
    @Environment(ApikeyVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var text = ""
    @State private var showProgress = false
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
                
                Button {
                    withAnimation {
                        showProgress = true
                    }
                    
                    vm.create(text)
                } label: {
                    HStack {
                        Text("Create and copy")
                        
                        Spacer()
                        
                        if showProgress {
                            ProgressView()
                        } else {
                            Image(systemName: "plus")
                        }
                    }
                    .foregroundStyle(text.isEmpty ? Color.secondary : .green)
                    .semibold()
                }
                .disabled(text.isEmpty)
            }
            .navigationTitle("Create API-key")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
        .onAppear {
            focus = true
        }
    }
}

#Preview {
    CreateApikey()
        .environment(ApikeyVM())
}
