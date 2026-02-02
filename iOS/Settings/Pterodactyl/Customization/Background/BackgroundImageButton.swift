import SwiftUI

struct BackgroundImageButton: View {
    @EnvironmentObject private var store: ValueStore
    
    @State private var imagePicker = false
    
    var body: some View {
        GlassyActionCard("Background", icon: "photo", tint: .blue) {
            imagePicker = true
        }
        .disabled(store.enableBisquitFall)
        .foregroundStyle(.foreground)
        .sheet($imagePicker) {
            NavigationStack {
                BackgroundImagePickerView()
            }
        }
    }
}

#Preview {
    List {
        BackgroundImageButton()
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
