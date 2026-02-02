import ScrechKit

struct AppIconCard: View {
    @EnvironmentObject private var store: ValueStore
    
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
                    .clipShape(.rect(cornerRadius: 16))
                    .frame(70)
                    .blur(radius: 5)
                    .matchedEffect("icon", in: animation)
            }
            
            Image(icon.img)
                .resizable()
                .frame(64)
                .clipShape(.rect(cornerRadius: 16))
                .padding(.horizontal, 4)
        }
        .frame(70)
        .onTapGesture {
            changeIcon()
        }
    }
    
    private func changeIcon() {
        grantAchievement("change_icon")
        
        withAnimation(.easeInOut) {
            store.currentIcon = icon
        }
    }
}
