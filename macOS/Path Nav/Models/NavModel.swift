// A navigation model used to persist and restore the navigation state

import SwiftUI
import PteroNet

@Observable
final class NavModel: Codable {
    /// The selected recipe category; otherwise returns `nil`
    var selectedTab: Tabs?
    
    /// The homogenous navigation state used by the app's navigation stacks
    var recipePath: [ServerAttributes]
    
    /// The leading columns' visibility state used by the app's navigation split views
    var columnVisibility: NavigationSplitViewVisibility
    
    /// The leading columns' visibility state used by the app's navigation split views
    var showExperiencePicker = false
    
    private static let decoder = JSONDecoder()
    
    private static let encoder = JSONEncoder()
    
    /// The URL for the JSON file that stores the recipe data
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
    /// visibility, selected recipe category, and navigation state based on recipe data
    init(
        columnVisibility: NavigationSplitViewVisibility = .automatic,
        selectedCategory: Tabs? = nil,
        recipePath: [ServerAttributes] = []
    ) {
        self.columnVisibility = columnVisibility
        self.selectedTab = selectedCategory
        self.recipePath = recipePath
    }
    
    /// Initialize a `DataModel` with the contents of a `URL`
    private convenience init(
        contentsOf url: URL,
        options: Data.ReadingOptions = .mappedIfSafe
    ) throws {
        let data = try Data(contentsOf: url, options: options)
        let model = try Self.decoder.decode(Self.self, from: data)
        
        self.init(
            columnVisibility: model.columnVisibility,
            selectedCategory: model.selectedTab,
            recipePath: model.recipePath
        )
    }
    
    /// Loads the navigation data for the navigation model from a previously saved state
    func load() throws {
        let model = try NavModel(contentsOf: Self.dataURL)
        
        selectedTab = model.selectedTab
        recipePath = model.recipePath
        columnVisibility = model.columnVisibility
    }
    
    /// Saves the JSON data for the navigation model at its current state
    func save() throws {
        try jsonData?.write(to: Self.dataURL)
    }
    
//    /// The selected recipe; otherwise returns `nil`
//    var selectedServer: Recipe? {
//        get {
//            recipePath.first
//        } set {
//            recipePath = [newValue].compactMap { $0 }
//        }
//    }
    var selectedServer: Set<ServerAttributes> {
        get {
            Set(recipePath)
        } set {
            recipePath = Array(newValue)
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
            
            selectedTab = model.selectedTab
            recipePath       = model.recipePath
            columnVisibility = model.columnVisibility
        }
    }
}
