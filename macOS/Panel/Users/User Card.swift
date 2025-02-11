import ScrechKit
import Kingfisher
import PteroNet

struct UserCard: View {
    @Environment(UsersVM.self) private var vm
    
    private let user: UserAttributes
    
    init(_ user: UserAttributes) {
        self.user = user
    }
    
    //    @State private var sheetDetails = false
    
    //#if os(tvOS)
    //    private let imageSize = 64.0
    //#else
    private let imageSize = 32.0
    //#endif
    
    var body: some View {
        //        Button {
        //            sheetDetails = true
        //        } label: {
        HStack {
            KFImage(URL(string: user.image))
                .resizable()
                .frame(width: imageSize, height: imageSize)
                .clipShape(.rect(cornerRadius: 10))
            
            VStack(alignment: .leading) {
                Text(user.username)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                if let destination = URL(string: "mailto:" + user.email) {
                    Link(destination: destination) {
                        Text(user.email)
                            .footnote()
                            .secondary()
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "lock.fill")
                .title2()
                .foregroundStyle(user.twoFaEnabled ? .green : .red)
        }
        .foregroundStyle(.foreground)
        .contextMenu {
            Section {
                MenuButton("Delete", role: .destructive, icon: "trash") {
                    vm.delete(user.uuid)
                }
            }
        }
        //        .sheet($sheetDetails) {
        //            UserView(user)
        //        }
    }
}

#Preview {
    List {
        UserCard(
            sampleJSON(.userAttributes)
        )
    }
}
