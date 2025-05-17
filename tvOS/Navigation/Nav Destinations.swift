import PteroNet

enum NavDestinations: Hashable {
    case toGuide,
         toPanel(_ server: ServerAttributes)
}
