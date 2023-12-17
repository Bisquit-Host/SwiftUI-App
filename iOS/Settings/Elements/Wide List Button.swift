import SwiftUI

struct WideListButton <S>: View where S: ShapeStyle {
    let name: LocalizedStringResource
    let backgroundColor: S
    let action: () -> Void
    
    init(_ name: LocalizedStringResource,
         color: S,
         action: @escaping () -> Void
    ) {
        self.name = name
        self.backgroundColor = color
        self.action = action
    }
    
    var body: some View {
        Button("\(name)") {
            action()
        }
        .foregroundStyle(.white)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(backgroundColor, in: .rect(cornerRadius: 16))
    }
}
