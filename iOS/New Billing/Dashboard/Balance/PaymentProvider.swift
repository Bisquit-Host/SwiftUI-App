import SwiftUI

struct PaymentProvider: Identifiable, Equatable {
    let id: String
    let name: String
    let image: ImageResource
    let tint: Color
}
