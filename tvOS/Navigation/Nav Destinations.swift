import SwiftUI

enum NavDestinations: Hashable {
    case toGuide
    case toPanel(_ id: String)
}
