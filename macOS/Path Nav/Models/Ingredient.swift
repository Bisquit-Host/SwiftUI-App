// A data model for an ingredient for a given recipe

import SwiftUI

struct Ingredient: CustomStringConvertible, Codable, Hashable, Identifiable {
    private(set) var id = UUID()
    private(set) var description: String
}
