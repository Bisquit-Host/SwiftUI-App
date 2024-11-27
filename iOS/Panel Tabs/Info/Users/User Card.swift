import ScrechKit
import Kingfisher
import PteroNet

struct UserCard: View {
    @Environment(UsersVM.self) private var vm
    
    private let user: UserAttributes
    
    init(_ user: UserAttributes) {
        self.user = user
    }
    
    @State private var sheetDetails = false
    
#if os(tvOS)
    private let imageSize: CGFloat = 64
#else
    private let imageSize: CGFloat = 32
#endif
    
    var body: some View {
        Button {
            sheetDetails = true
        } label: {
            HStack {
                KFImage(URL(string: user.image))
                    .resizable()
                    .frame(width: imageSize, height: imageSize)
                    .clipShape(.rect(cornerRadius: 10))
                
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
                
                Image(systemName: "lock.fill")
                    .title2()
                    .foregroundStyle(user.twoFaEnabled ? .green : .red)
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
                    vm.delete(user.uuid)
                }
            }
        }
#endif
    }
}

#Preview {
    List {
        UserCard(
            sampleJSON(.userAttributes)
        )
    }
}
