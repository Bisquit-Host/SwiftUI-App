import SwiftUI
import PteroNet

struct DatabaseCard: View {
    @Environment(DatabaseVM.self) private var vm
    
    private let database: DatabaseAttributes
    
    init(_ database: DatabaseAttributes) {
        self.database = database
    }
    
    var body: some View {
        let host = database.host
        
        HStack {
            VStack(alignment: .leading) {
                Text(database.name)
                
                let endpoint = Text(host.address + ":\(host.port)")
                    .foregroundStyle(.primary)
                
                Text("Endpoint: \(endpoint)")
                    .footnote()
                    .secondary()
                
                let id = Text(database.id)
                    .foregroundStyle(.primary)
                
                Text("Identifier: \(id)")
                    .footnote()
                    .secondary()
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        }
        .frame(minWidth: 200, maxWidth: 800)
        .contextMenu {
            Button("Rotate password", systemImage: "lock.open.rotation") {
                Task {
                    await vm.rotatePassword(database.id)
                }
            }
        }
    }
}

#Preview {
    DatabaseCard(PreviewProp.databaseAttributes)
        .darkSchemePreferred()
        .environment(DatabaseVM(""))
}
