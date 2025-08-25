import SwiftUI

struct DiscoverCardLayout: View {
    private let link: DiscoverModel
    
    init(_ link: DiscoverModel) {
        self.link = link
    }
    
    private var avgColor: UIColor? {
        UIImage(resource: link.image).findAverageColor(.simple)
    }
    
    private let imageSize = 60.0
    
    var body: some View {
        HStack {
            ZStack {
                if let avgColor {
                    RoundedRectangle(cornerRadius: 17)
                        .foregroundStyle(Color(avgColor))
                        .frame(imageSize + 3)
                }
                
                Image(link.image)
                    .resizable()
                    .frame(imageSize)
                    .clipShape(.rect(cornerRadius: 16))
            }
            
            VStack(alignment: .leading) {
                Text(link.subtitle)
                    .semibold()
                    .rounded()
                    .secondary()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text(link.title)
                    .title2(.bold, design: .rounded)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 25))
        .padding(2)
        .background(Color(uiColor: avgColor ?? .gray), in: .rect(cornerRadius: 27))
    }
}

#Preview {
    NavigationStack {
        Discover()
    }
}
