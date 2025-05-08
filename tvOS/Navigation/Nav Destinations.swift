import PteroNet

enum NavDestinations: Hashable {
    case toGuide
    case toPanel(_ server: ServerAttributes)
}
