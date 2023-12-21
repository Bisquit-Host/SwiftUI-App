import ScrechKit
import Kingfisher
import PteroNet

struct UserCard: View {
    @Environment(UsersVM.self) private var vm
    
    private let user: UserListAttributes
    
    init(_ user: UserListAttributes) {
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
                        .foregroundStyle(.secondary)
#endif
                }
                
                Spacer()
                
                Image(systemName: "lock.fill")
                    .title2()
                    .foregroundStyle(user.twoFaEnabled ? .green : .red)
            }
        }
#if !os(watchOS)
        .contextMenu {
            Section {
                MenuButton("Delete", role: .destructive, icon: "trash") {
                    vm.delete(user.uuid)
                }
            }
        }
#endif
        .sheet($sheetDetails) {
            UserView(user)
        }
    }
}

#Preview {
    List {
        UserCard(
            sampleJSON(.userAttributes)
        )
    }
}
