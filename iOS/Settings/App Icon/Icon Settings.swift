import SwiftUI

struct IconSettings: View {
    var body: some View {
        VStack {
            Text("Icon".uppercased())
                .secondary()
                .footnote()
                .frame(maxWidth: .infinity, alignment: .center)
            
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
