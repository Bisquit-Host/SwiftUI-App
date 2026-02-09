import SwiftUI
import Kingfisher
import PteroNet

struct UserCard: View {
    @Environment(UsersVM.self) private var vm
    
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
                
                VStack(alignment: .leading) {
                    Text(user.username)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
#if !os(watchOS)
                    Text(user.email)
                        .footnote()
                        .secondary()
#endif
                }
                
                Spacer()
                
                if !user.twoFaEnabled {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .title3()
                        .foregroundStyle(.yellow)
                }
            }
            .foregroundStyle(.foreground)
        }
        .sheet($sheetDetails) {
            NavigationStack {
                UserView(user)
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
        UserCard(PreviewProp.userAttributes)
    }
    .darkSchemePreferred()
    .environment(UsersVM(""))
}
