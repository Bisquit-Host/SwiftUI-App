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
            HStack {
                KFImage(imageUrl)
                    .resizable()
                    .frame(width: imageSize, height: imageSize)
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
            .padding()
            .background(.ultraThinMaterial.opacity(0.3), in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.gray.opacity(0.25), lineWidth: 1)
            }
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
        UserCard(sampleJSON(.userAttributes))
    }
}
