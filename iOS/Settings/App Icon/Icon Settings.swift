import SwiftUI

struct IconSettings: View {
    var body: some View {
        VStack {
            Text("Icon")
                .headline()
                .secondary()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            AppIconPicker()
        }
        .transparentSection()
    }
}

#Preview {
    List {
        IconSettings()
    }
    .environmentObject(ValueStore())
}
