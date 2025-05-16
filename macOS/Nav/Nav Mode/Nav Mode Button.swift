import SwiftUI

struct NavModeButton: View {
    @Environment(NavModel.self) private var nav
    
    @EnvironmentObject private var store: ValueStore
    
    private var icon: String {
        store.navMode?.imageName ?? "questionmark"
    }
    
    private var name: LocalizedStringKey {
        store.navMode?.localizedName ?? ""
    }
    
    var body: some View {
        @Bindable var nav = nav
        
        Button {
            nav.showNavModePicker = true
        } label: {
            Label(name, systemImage: icon)
        }
        .help("Change your navigation mode")
    }
}

#Preview {
    NavModeButton()
        .environment(NavModel.shared)
}
