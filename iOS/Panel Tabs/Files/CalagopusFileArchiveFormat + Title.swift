import Calagopus

extension CalagopusFileArchiveFormat {
    /// Formats the panel can stream a backup download as
    static let streamable: [Self] = [.tar, .tarGz, .tarXz, .tarLzip, .tarBz2, .tarLz4, .tarZstd, .zip]
    
    var title: String {
        switch self {
        case .tar: ".tar"
        case .tarGz: ".tar.gz"
        case .tarXz: ".tar.xz"
        case .tarLzip: ".tar.lz"
        case .tarBz2: ".tar.bz2"
        case .tarLz4: ".tar.lz4"
        case .tarZstd: ".tar.zst"
        case .zip: ".zip"
        case .sevenZip: ".7z"
        }
    }
}
