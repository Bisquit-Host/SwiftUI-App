import SwiftUI
import PteroNet

@Observable
final class NavModel: Codable {
    var columnVisibility: NavigationSplitViewVisibility
    var selectedTab: PanelTab?
    var serverPath: [ServerAttributes]
    var path: [Route]
    var folderPath: [String]
    
    var showNavModePicker = false
    
    private static let decoder = JSONDecoder()
    private static let encoder = JSONEncoder()
    
    let enabledTabs: [PanelTab] = [
        //                .info,
        //                .console,
        .files,
        .backups,
        //                .settings,
        //                .startup,
            .users,
        //                .schedules,
        .databases,
        .allocations,
        .logs,
        .subdomains
    ]
    
    private enum CodingKeys: String, CodingKey {
        case _selectedTab = "selectedTab",
             _serverPath = "serverPath",
             _path = "path",
             _columnVisibility = "columnVisibility",
             _folderPath = "folderPath"
    }
    
    /// The URL for the JSON file that stores the server data
    private static var dataURL: URL {
        .cachesDirectory.appending(path: "NavigationData.json")
    }
    
    /// Shared singleton NavModel obj
    static let shared = {
        if let model = try? NavModel(contentsOf: dataURL) {
            model
        } else {
            NavModel()
        }
    }()
    
    /// Initialize a `NavModel` that enables programmatic control of leading columns’
    /// visibility, selected server category, and navigation state based on server data
    init(
        columnVisibility: NavigationSplitViewVisibility = .automatic,
        selectedCategory: PanelTab? = nil,
        serverPath: [ServerAttributes] = [],
        path: [Route] = [],
        folderPath: [String] = []
    ) {
        self.columnVisibility = columnVisibility
        self.selectedTab = selectedCategory
        self.serverPath = serverPath
        self.path = path
        self.folderPath = folderPath
    }
    
    /// Initialize a `NavModel` with the contents of a `URL`
    private convenience init(contentsOf url: URL, options: Data.ReadingOptions = .mappedIfSafe) throws {
        let data = try Data(contentsOf: url, options: options)
        let model = try Self.decoder.decode(NavModel.self, from: data)
        
        self.init(
            columnVisibility: model.columnVisibility,
            selectedCategory: model.selectedTab,
            serverPath: model.serverPath,
            path: model.path,
            folderPath: model.folderPath
        )
    }
    
    /// Loads the nav data for the navigation model from a previously saved state
    func load() throws {
        print("New load")
        
        let model = try NavModel(contentsOf: Self.dataURL)
        
        selectedTab      = model.selectedTab
        serverPath       = model.serverPath
        columnVisibility = model.columnVisibility
        path             = model.path
        folderPath       = model.folderPath
    }
    
    /// Saves the JSON data for the navigation model at its current state
    func save() throws {
        print("Nav save")
        
        try jsonData?.write(to: Self.dataURL)
    }
    
    var selectedServers: Set<ServerAttributes> {
        get {
            Set(serverPath)
        } set {
            serverPath = Array(newValue)
        }
    }
    
    /// The JSON data used to encode and decode the navigation model at its current state
    var jsonData: Data? {
        get {
            return try? Self.encoder.encode(self)
        } set {
            guard
                let data = newValue,
                let model = try? Self.decoder.decode(NavModel.self, from: data)
            else {
                return
            }
            
            selectedTab      = model.selectedTab
            serverPath       = model.serverPath
            columnVisibility = model.columnVisibility
            path             = model.path
            folderPath       = model.folderPath
        }
    }
    
    func clearNavCache() {
        do {
            try FileManager.default.removeItem(at: Self.dataURL)
        } catch {
            print(error)
        }
    }
}
