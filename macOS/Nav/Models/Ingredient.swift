// A data model for an ingredient for a given server

import SwiftUI

struct Ingredient: CustomStringConvertible, Codable, Hashable, Identifiable {
    private(set) var id = UUID()
    private(set) var description: String
}
