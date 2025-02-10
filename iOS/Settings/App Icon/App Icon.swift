import ScrechKit

struct AppIcon: View {
    private let icon: Icon
    private let isSelected: Bool
    
    init(_ icon: Icon, isSelected: Bool) {
        self.icon = icon
        self.isSelected = isSelected
    }
    
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            if isSelected {
                Image(icon.img)
                    .resizable()
                    .blur(radius: 5)
                    .frame(width: 70, height: 70)
                    .matchedEffect("icon", in: animation)
            }
            
            Image(icon.img)
                .resizable()
                .frame(width: 64, height: 64)
                .cornerRadius(10)
                .padding(.horizontal, 4)
        }
        .frame(width: 80, height: 90)
    }
}
