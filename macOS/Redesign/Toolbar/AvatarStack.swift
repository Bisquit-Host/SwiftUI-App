import SwiftUI

struct AvatarStack: View {
    var body: some View {
        HStack(spacing: -10) {
            AvatarView(.michael)
            AvatarView(.john)
            AvatarView(.dawne)
        }
    }
}
