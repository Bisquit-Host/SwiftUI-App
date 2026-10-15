import Foundation

struct DatabaseInstanceExport: Identifiable {
    let id = UUID()
    let name: String
    let contents: String
}
