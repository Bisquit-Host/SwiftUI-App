import ScrechKit
import Kingfisher
import PteroNet

struct UserCard: View {
    @Environment(UsersVM.self) private var vm
    
    private let user: UserAttributes
    private let imageUrl: URL?
    
    init(_ user: UserAttributes) {
        self.user = user
        self.imageUrl = URL(string: user.image)
    }
    
    @State private var sheetDetails = false
    
#if os(tvOS)
    private let imageSize = 64.0
#else
    private let imageSize = 40.0
#endif
    
    var body: some View {
        Button {
            sheetDetails = true
        } label: {
            HStack(spacing: 16) {
                KFImage(imageUrl)
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
            UserView(user)
        }
#if !os(watchOS)
        .contextMenu {
            MenuButton("Details", icon: "info.circle") {
                sheetDetails = true
            }
            
            Section {
                MenuButton("Delete", role: .destructive, icon: "trash") {
                    Task {
                        await vm.delete(user.uuid)
                    }
                }
            }
        }
#endif
    }
}

#Preview {
    List {
        UserCard(sampleJSON(.userAttributes))
    }
    .darkSchemePreferred()
    .environment(UsersVM(""))
}
