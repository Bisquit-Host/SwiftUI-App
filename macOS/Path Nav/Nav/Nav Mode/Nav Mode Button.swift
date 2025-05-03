import SwiftUI

struct NavModeButton: View {
    @Environment(NavModel.self) private var navModel
    
    @AppStorage("nav_mode") private var navMode: NavMode?
    
    private var icon: String {
        navMode?.imageName ?? "questionmark"
    }
    
    private var name: LocalizedStringKey {
        navMode?.localizedName ?? ""
    }
    
    var body: some View {
        Button {
            navModel.showNavModePicker = true
        } label: {
            Label(name, systemImage: icon)
        }
        .help("Choose your navigation mode")
    }
}

#Preview {
    NavModeButton()
        .environment(NavModel.shared)
}
