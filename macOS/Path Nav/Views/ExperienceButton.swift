// An button that presents the navigation experience picker when its action is invoked

import SwiftUI

struct ExperienceButton: View {
    @Environment(NavModel.self) private var nav
    
    var body: some View {
        Button {
            nav.showExperiencePicker = true
        } label: {
            Label("Experience", systemImage: "wand.and.stars")
                .help("Choose your navigation experience")
        }
    }
}

#Preview() {
    ExperienceButton()
        .environment(NavModel.shared)
}
