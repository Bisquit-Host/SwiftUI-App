import SwiftUI
import Kingfisher
import Calagopus

struct SubuserCard: View {
    @Environment(SubuserVM.self) private var vm
    
    private let user: UserAttributes
    
    init(_ user: UserAttributes) {
        self.user = user
    }
    
    @State private var sheetDetails = false
    
    private let imageSize = 32.0
    
    var body: some View {
        Button {
            sheetDetails = true
        } label: {
            HStack {
                KFImage(URL(string: user.image))
                    .resizable()
                    .frame(imageSize)
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
                
                Image(systemName: "lock")
                    .title2()
                    .foregroundStyle(user.twoFaEnabled ? .green : .red)
            }
        }
        .foregroundStyle(.foreground)
        .buttonStyle(.plain)
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        }
        .frame(minWidth: 200, maxWidth: 800)
        .contextMenu {
            Button("Delete", systemImage: "trash", role: .destructive) {
                Task {
                    await vm.delete(user.uuid)
                }
            }
        }
        .sheet($sheetDetails) {
            NavigationStack {
                SubuserView(user)
            }
        }
    }
}

#Preview {
    List {
        SubuserCard(PreviewProp.userAttributes)
    }
    .darkSchemePreferred()
    .environment(SubuserVM(""))
}
