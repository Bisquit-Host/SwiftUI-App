import SwiftUI

struct AvatarView: View, Identifiable {
    let person: Person
    
    var id: UUID {
        person.id
    }
    
    init(_ p: Person) {
        person = p
    }
    
    var body: some View {
        Text(person.initials)
            .caption(.bold)
            .frame(28)
            .background {
                Circle()
                    .fill(person.tint)
            }
            .overlay {
                Circle()
                    .stroke(.black.opacity(0.3))
            }
            .foregroundStyle(.white)
            .accessibilityLabel(person.name)
    }
}
