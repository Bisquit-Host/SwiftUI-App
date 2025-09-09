import SwiftUI

struct DiscoverCardLabel: View {
    private let title, subtitle: LocalizedStringKey
    private let image: ImageResource
    
    init(
        _ title: LocalizedStringKey,
        subtitle: LocalizedStringKey,
        image: ImageResource
    ) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
    
    private var avgColor: UIColor? {
        UIImage(resource: image).findAverageColor(.simple)
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
                
                Image(image)
                    .resizable()
                    .frame(imageSize)
                    .clipShape(.rect(cornerRadius: 16))
            }
            
            VStack(alignment: .leading) {
                Text(subtitle)
                    .semibold()
                    .rounded()
                    .secondary()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text(title)
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
