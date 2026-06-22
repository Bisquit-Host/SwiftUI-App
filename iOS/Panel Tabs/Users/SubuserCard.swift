import SwiftUI
import Kingfisher
import Calagopus

struct SubuserCard: View {
    @Environment(SubuserVM.self) private var vm
    
    private let user: UserAttributes
    private let imageURL: URL?
    
    init(_ user: UserAttributes) {
        self.user = user
        self.imageURL = URL(string: user.image)
    }
    
    @State private var sheetDetails = false
    
    private let imageSize = System.isTV ? 64.0 : 40
    
    var body: some View {
        Button {
            sheetDetails = true
        } label: {
            HStack(spacing: 16) {
                KFImage(imageURL)
                    .resizable()
                    .frame(imageSize)
                    .clipShape(.circle)
                
                Text(user.username)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Spacer()
                
                if !user.totpEnabled {
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
#if !os(watchOS)
        .contextMenu {
            Button("Details", systemImage: "info.circle") {
                sheetDetails = true
            }
            
            Divider()
            
            Button("Delete", systemImage: "trash", role: .destructive) {
                Task {
                    await vm.delete(user.uuid)
                }
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
