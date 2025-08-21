import SwiftUI

struct DiscoverCardLayout: View {
    private let link: DiscoverModel
    
    init(_ link: DiscoverModel) {
        self.link = link
    }
    
    private var screenWidth: CGFloat {
#if os(visionOS)
        500
#else
        if UIDevice.current.userInterfaceIdiom == .pad {
            380
        } else {
            UIScreen.main.bounds.width
        }
#endif
    }
    
    private var squareSize: CGFloat {
        screenWidth * 0.45
    }
    
    private var averageColor: UIColor? {
        UIImage(resource: link.image).findAverageColor(.simple)
    }
    
    private let imageSize = 60.0
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                if let averageColor {
                    RoundedRectangle(cornerRadius: 17)
                        .foregroundStyle(Color(averageColor))
                        .frame(imageSize + 3)
                }
                
                Image(link.image)
                    .resizable()
                    .frame(imageSize)
                    .clipShape(.rect(cornerRadius: 16))
            }
            
            Spacer()
            
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
                .frame(maxWidth: squareSize, alignment: .leading)
        }
        .padding(10)
        .frame(squareSize)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 25))
        .padding(2)
        .background(Color(uiColor: averageColor ?? .gray), in: .rect(cornerRadius: 27))
    }
}
