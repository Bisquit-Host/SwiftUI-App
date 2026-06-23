import Calagopus

enum NavDestinations: Hashable {
    case toGuide,
         toPanel(_ id: String)
}
