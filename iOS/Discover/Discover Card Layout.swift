import SwiftUI

struct DiscoverCardLayout: View {
    private let link: DiscoverModel
    
    init(_ link: DiscoverModel) {
        self.link = link
    }
    
    private let imageSize = 60.0
    
    private var screenWidth: CGFloat {
#if os(visionOS)
        100
#else
        UIScreen.main.bounds.width
#endif
    }
    
    private var squareSize: CGFloat {
        screenWidth * 0.45
    }
    
    private var averageColor: UIColor? {
        UIImage(resource: link.image).findAverageColor(.simple)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                if let averageColor {
                    RoundedRectangle(cornerRadius: 17)
                        .foregroundStyle(Color(averageColor))
                        .frame(width: imageSize + 3, height: imageSize + 3)
                }
                
                Image(link.image)
                    .resizable()
                    .frame(width: imageSize, height: imageSize)
                    .clipShape(.rect(cornerRadius: 16))
            }
            
            Spacer()
            
            Text(link.subtitle)
                .rounded()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .secondary()
                .semibold()
            
            Text(link.title)
                .rounded()
                .title(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: squareSize, alignment: .leading)
        }
        .padding(10)
        .frame(width: squareSize, height: squareSize)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 25))
        .padding(2)
        .background(Color(uiColor: averageColor ?? .gray), in: .rect(cornerRadius: 27))
    }
}
