import MusicKit

enum DiscoverSong: CaseIterable {
    case vibratoKombayn, vadimKupilIPv6, bisquitus
    
    var title: String {
        switch self {
        case .vibratoKombayn: "Вибратор-комбайн"
        case .vadimKupilIPv6: "Вадим купил IPv6"
        case .bisquitus: "Bisquitus"
        }
    }
    
    var id: MusicItemID {
        switch self {
        case .vibratoKombayn: MusicItemID("1819051074")
        case .vadimKupilIPv6: MusicItemID("1770029033")
        case .bisquitus: MusicItemID("1764417433")
        }
    }
}
