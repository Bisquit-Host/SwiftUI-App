import SwiftUI

struct NavModeButton: View {
    @Environment(NavModel.self) private var nav
    
    @AppStorage("nav_mode") private var navMode: NavMode?
    
    private var icon: String {
        navMode?.imageName ?? "questionmark"
    }
    
    private var name: LocalizedStringKey {
        navMode?.localizedName ?? ""
    }
    
    var body: some View {
        @Bindable var nav = nav
        
        Button {
            nav.showNavModePicker = true
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
