import SwiftUI

enum Icon: String, Identifiable, CaseIterable {
    case def, cool, love, streamer, coin
    
    var id: String {
        self.rawValue
    }
    
    var img: ImageResource {
        switch self {
        case .def:      .defaultIcon
        case .cool:     .coolIcon
        case .love:     .loveIcon
        case .streamer: .streamerIcon
        case .coin:     .coinIcon
        }
    }
}
