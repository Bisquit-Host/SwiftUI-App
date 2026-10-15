import Calagopus

extension CalagopusDatabaseInstanceType {
    var symbol: String {
        switch self {
        case .postgres: "cylinder.split.1x2"
        case .mariadb: "tray.2"
        case .mongodb: "leaf"
        case .redis: "bolt.horizontal"
        }
    }
}
