import SwiftUI

struct NavModeButton: View {
    @Environment(NavModel.self) private var nav
    
    @EnvironmentObject private var store: ValueStore
    
    private var icon: String {
        store.navMode?.icon ?? "questionmark"
    }
    
    private var name: LocalizedStringKey {
        store.navMode?.name ?? ""
    }
    
    var body: some View {
        @Bindable var nav = nav
        
        Button(name, systemImage: icon) {
            nav.showNavModePicker = true
        }
        .help("Change your navigation mode")
    }
}

#Preview {
    NavModeButton()
        .environment(NavModel.shared)
}
