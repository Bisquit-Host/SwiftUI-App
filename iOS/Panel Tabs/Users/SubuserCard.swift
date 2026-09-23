import ScrechKit
import Calagopus

struct SubuserCard: View {
    @Environment(SubuserVM.self) private var vm
    
    private let user: CalagopusServerSubuser
    
    init(_ user: CalagopusServerSubuser) {
        self.user = user
    }
    
    @State private var sheetDetails = false
    
    private let imageSize = 40.0
    
    var body: some View {
        Button {
            sheetDetails = true
        } label: {
            HStack(spacing: 16) {
                SubuserImage(user.user.avatar, username: user.user.username, size: imageSize)
                
                Text(user.user.username)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Spacer()
                
                if !user.user.totpEnabled {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .title3()
                        .foregroundStyle(.yellow)
                }
            }
            .foregroundStyle(.foreground)
        }
        .sheet($sheetDetails) {
            NavigationStack {
                SubuserView(user)
            }
        }
        .swipeActions {
            AsyncButton("Delete", systemImage: "trash", role: .destructive) {
                await vm.delete(user.user.uuid)
            }
            .labelStyle(.iconOnly)
        }
#if !os(watchOS)
        .contextMenu {
            Button("Details", systemImage: "info.circle") {
                sheetDetails = true
            }
            
            Divider()
            
            AsyncButton("Delete", systemImage: "trash", role: .destructive) {
                await vm.delete(user.user.uuid)
            }
        }
#endif
    }
}

#Preview {
    List {
        SubuserCard(PreviewProp.userAttributes)
    }
    .darkSchemePreferred()
    .environment(SubuserVM(""))
}
