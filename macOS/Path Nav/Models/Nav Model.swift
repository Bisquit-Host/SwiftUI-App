import SwiftUI
import PteroNet

struct NavModelData: Codable {
    var selectedTab: PanelTab?
    var serverPath: [ServerAttributes]
    var path: [Route]
    var columnVisibility: NavigationSplitViewVisibility
    var folderPath: [String]
}

@Observable
final class NavModel {
    /// The selected server category; otherwise returns `nil`
    var selectedTab: PanelTab?
    
    /// The homogenous navigation state used by the app's navigation stacks
    var serverPath: [ServerAttributes]
    var path: [Route]
    var folderPath: [String]
    
    /// The leading columns' visibility state used by the app's navigation split views
    var columnVisibility: NavigationSplitViewVisibility
    
    /// The leading columns' visibility state used by the app's navigation split views
    var showNavModePicker = false
    
    private static let decoder = JSONDecoder()
    private static let encoder = JSONEncoder()
    
    /// The URL for the JSON file that stores the server data
    private static var dataURL: URL {
        .cachesDirectory.appending(path: "NavigationData.json")
    }
    
    /// The shared singleton navigation model object
    static let shared = {
        if let model = try? NavModel(contentsOf: dataURL) {
            model
        } else {
            NavModel()
        }
    }()
    
    /// Initialize a `NavigationModel` that enables programmatic control of leading columns’
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
    private convenience init(
        contentsOf url: URL,
        options: Data.ReadingOptions = .mappedIfSafe
    ) throws {
        let data = try Data(contentsOf: url, options: options)
        let model = try Self.decoder.decode(NavModelData.self, from: data)
        
        self.init(
            columnVisibility: model.columnVisibility,
            selectedCategory: model.selectedTab,
            serverPath: model.serverPath,
            path: model.path,
            folderPath: model.folderPath
        )
    }
    
    /// Loads the navigation data for the navigation model from a previously saved state
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
            let dataStruct = NavModelData(
                selectedTab: selectedTab,
                serverPath: serverPath,
                path: path,
                columnVisibility: columnVisibility,
                folderPath: folderPath
            )
            
            return try? Self.encoder.encode(dataStruct)
        } set {
            guard
                let data = newValue,
                let model = try? Self.decoder.decode(NavModelData.self, from: data)
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
