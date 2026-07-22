import SwiftUI
import BisquitoNet

struct TicketCardAvatar: View {
    private let user: SupportMessageUserDTO
    
    init(_ user: SupportMessageUserDTO) {
        self.user = user
    }
    
    var body: some View {
        let initial = user.name.first.map { String($0).uppercased() } ?? "?"
        let avatarURL = user.avatar.flatMap { avatar in
            if let url = URL(string: avatar), url.scheme != nil {
                return url
            }
            
            guard let baseURL = URL(string: "https://api.bisquit.host") else { return nil }
            let normalizedPath = avatar.drop(while: { $0 == "/" })
            return baseURL.appending(path: String(normalizedPath))
        }
        
        Group {
            if let avatarURL {
                AsyncImage(url: avatarURL) {
                    switch $0 {
                    case .empty:
                        Circle()
                            .fill(Color.accentColor.gradient)
                            .overlay {
                                Text(initial)
                                    .caption(.semibold)
                                    .foregroundStyle(.white)
                            }
                        
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                        
                    case .failure:
                        Circle()
                            .fill(Color.accentColor.gradient)
                            .overlay {
                                Text(initial)
                                    .caption(.semibold)
                                    .foregroundStyle(.white)
                            }
                        
                    @unknown default:
                        Circle()
                            .fill(Color.accentColor.gradient)
                            .overlay {
                                Text(initial)
                                    .caption(.semibold)
                                    .foregroundStyle(.white)
                            }
                    }
                }
            } else {
                Circle()
                    .fill(Color.accentColor.gradient)
                    .overlay {
                        Text(initial)
                            .caption(.semibold)
                            .foregroundStyle(.white)
                    }
            }
        }
        .frame(width: 32, height: 32)
        .clipShape(.circle)
    }
}
