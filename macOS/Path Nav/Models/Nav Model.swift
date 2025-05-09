// A navigation model used to persist and restore the navigation state

import SwiftUI
import PteroNet

@Observable
final class NavModel: Codable {
    /// The selected server category; otherwise returns `nil`
    var selectedTab: PanelTab?
    
    /// The homogenous navigation state used by the app's navigation stacks
    var serverPath: [ServerAttributes]
    var path: [Route] = []
    
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
        path: [Route] = []
    ) {
        self.columnVisibility = columnVisibility
        self.selectedTab = selectedCategory
        self.serverPath = serverPath
        self.path = path
    }
    
    /// Initialize a `ServerListVM` with the contents of a `URL`
    private convenience init(
        contentsOf url: URL,
        options: Data.ReadingOptions = .mappedIfSafe
    ) throws {
        let data = try Data(contentsOf: url, options: options)
        let model = try Self.decoder.decode(Self.self, from: data)
        
        self.init(
            columnVisibility: model.columnVisibility,
            selectedCategory: model.selectedTab,
            serverPath: model.serverPath,
            path: model.path
        )
    }
    
    /// Loads the navigation data for the navigation model from a previously saved state
    func load() throws {
        print("New load")
        
        let model = try NavModel(contentsOf: Self.dataURL)
        
        selectedTab =      model.selectedTab
        serverPath =       model.serverPath
        columnVisibility = model.columnVisibility
        path =             model.path
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
            try? Self.encoder.encode(self)
        } set {
            guard
                let data = newValue,
                let model = try? Self.decoder.decode(Self.self, from: data)
            else {
                return
            }
            
            selectedTab      = model.selectedTab
            serverPath       = model.serverPath
            columnVisibility = model.columnVisibility
            path             = model.path
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
