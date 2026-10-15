import ScrechKit
import Calagopus

struct DatabaseCard: View {
    private let instance: CalagopusDatabaseInstance
    
    init(_ instance: CalagopusDatabaseInstance) {
        self.instance = instance
    }
    
    var body: some View {
        NavigationLink {
            DatabaseDetails(instance)
        } label: {
            VStack(alignment: .leading) {
                Text(instance.name)
                    .lineLimit(1)
                
                Text(instance.type.label)
                    .footnote()
                    .secondary()
            }
        }
    }
}

#Preview {
    List {
        DatabaseCard(PreviewProp.databaseInstance)
    }
    .darkSchemePreferred()
}
