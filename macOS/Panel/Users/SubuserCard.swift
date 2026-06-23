import SwiftUI
import Kingfisher
import Calagopus

struct SubuserCard: View {
    @Environment(SubuserVM.self) private var vm
    
    private let user: CalagopusServerSubuser
    
    init(_ user: CalagopusServerSubuser) {
        self.user = user
    }
    
    @State private var sheetDetails = false
    
    private let imageSize = 32.0
    
    var body: some View {
        Button {
            sheetDetails = true
        } label: {
            HStack {
                KFImage(URL(string: user.user.avatar ?? ""))
                    .resizable()
                    .frame(imageSize)
                    .clipShape(.rect(cornerRadius: 10))
                
                VStack(alignment: .leading) {
                    Text(user.user.username)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                
                Spacer()
                
                Image(systemName: "lock")
                    .title2()
                    .foregroundStyle(user.user.totpEnabled ? .green : .red)
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
                    await vm.delete(user.user.uuid)
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
