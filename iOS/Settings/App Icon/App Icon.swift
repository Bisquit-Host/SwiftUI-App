import ScrechKit
import Kingfisher

struct AppIcon: View {
    private let iconName: String
    private let isSelected: Bool
    
    init(_ iconName: String, isSelected: Bool) {
        self.iconName = iconName
        self.isSelected = isSelected
    }
    
    @Namespace var animation
    
    var body: some View {
        VStack {
            KFImage(getImageUrl(iconName + "Icon"))
                .resizable()
                .fade(duration: 0.25)
                .frame(width: 64, height: 64)
                .cornerRadius(10)
                .padding(.horizontal, 4)
            
            ZStack {
                if isSelected {
                    Capsule(.blue)
                        .frame(width: 64, height: 20)
                        .matchedEffect("icon", in: animation)
                }
                
                Text(iconName)
                    .footnote(.bold, design: .rounded)
            }
        }
    }
}
