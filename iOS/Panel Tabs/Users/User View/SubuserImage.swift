import SwiftUI
import Kingfisher

struct SubuserImage: View {
    private let imageURL: URL?
    private let initials: String
    private let size: CGFloat
    
    init(_ image: String?, username: String, size: CGFloat = 32) {
        self.imageURL = image.flatMap(URL.init(string:))
        self.initials = Self.initials(for: username)
        self.size = size
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.quaternary)

            if let imageURL {
                KFImage(imageURL)
                    .resizable()
            } else {
                Text(initials)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.secondary)
            }
        }
        .frame(size)
        .clipShape(.circle)
    }

    private static func initials(for username: String) -> String {
        let words = username.split(separator: " ")

        if words.count == 1 {
            return String(username.prefix(2)).uppercased()
        }

        return String(words.prefix(2).compactMap(\.first)).uppercased()
    }
}

#Preview {
    VStack {
        SubuserImage(
            "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Example_image.svg/600px-Example_image.svg.png",
            username: "Example User"
        )

        SubuserImage(nil, username: "Example User")
    }
    .darkSchemePreferred()
}
