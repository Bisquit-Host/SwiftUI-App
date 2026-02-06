import Foundation

enum MinecraftPluginProvider: String, CaseIterable, Identifiable {
    case curseforge, hangar, modrinth, spigotmc, polymart
    
    init?(providerValue: String?) {
        guard let providerValue = providerValue?.lowercased() else {
            return nil
        }
        
        self.init(rawValue: providerValue)
    }
    
    var id: String {
        rawValue
    }
    
    var name: String {
        switch self {
        case .curseforge: "CurseForge"
        case .hangar: "Hangar"
        case .modrinth: "Modrinth"
        case .spigotmc: "SpigotMC"
        case .polymart: "Polymart"
        }
    }
}
