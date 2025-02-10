import SwiftUI

enum Icon: String, Identifiable, CaseIterable {
    var id: String {
        self.rawValue
    }
    
    case def,
         cool,
         love,
         streamer,
         coin,
         modern
    
    var img: ImageResource {
        switch self {
        case .def:      .defaultIcon
        case .cool:     .coolIcon
        case .love:     .loveIcon
        case .streamer: .streamerIcon
        case .coin:     .coinIcon
        case .modern:   .modernIcon
        }
    }
}
