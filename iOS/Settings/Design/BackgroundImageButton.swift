import SwiftUI

struct BackgroundImageButton: View {
    @EnvironmentObject private var store: ValueStore
    
    @State private var imagePicker = false
    
    var body: some View {
        Button {
            imagePicker = true
        } label: {
            Label {
                Text("Background image")
            } icon: {
                Image(systemName: "photo")
                    .foregroundStyle(.blue)
            }
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
    .environmentObject(ValueStore())
}
