import ScrechKit
import Calagopus

struct DatabaseInstanceCreateSheet: View {
    @Environment(DatabaseInstanceVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var templateID: String?
    @State private var image: String?
    
    private var template: CalagopusDatabaseInstanceTemplate? {
        vm.templates.first { $0.id == templateID }
    }
    
    private var images: [String] {
        template?.dockerImages.keys.sorted() ?? []
    }
    
    private var isValid: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return template != nil && !trimmed.isEmpty
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .limitInputLength($name, length: 31)
            }
            
            Section {
                Picker("Template", selection: $templateID) {
                    ForEach(vm.templates) {
                        Text("\($0.name) · \($0.type.label)")
                            .tag($0.id as String?)
                    }
                }
                
                if images.count > 1 {
                    Picker("Docker image", selection: $image) {
                        ForEach(images, id: \.self) {
                            Text($0)
                                .tag($0 as String?)
                        }
                    }
                }
            } footer: {
                if let template {
                    DatabaseInstanceTemplateLimits(template)
                }
            }
        }
        .navigationTitle("New Managed Database")
        .toolbarTitleDisplayMode(.inline)
        .onAppear {
            if templateID == nil {
                templateID = vm.templates.first?.id
            }
        }
        .onChange(of: templateID, initial: true) {
            image = images.first
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark", role: .cancel) {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                AsyncButton("Create", systemImage: "checkmark", role: .confirm, action: create)
                    .disabled(!isValid)
            }
        }
    }
    
    private func create() async {
        guard let template else {
            return
        }
        
        if await vm.createInstance(template: template, name: name, image: image) {
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        DatabaseInstanceCreateSheet()
    }
    .darkSchemePreferred()
    .environment(DatabaseInstanceVM(""))
}
