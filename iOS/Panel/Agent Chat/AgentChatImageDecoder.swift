import Foundation
import ImageIO

func agentChatCGImage(from data: Data) -> CGImage? {
    guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }

    return CGImageSourceCreateImageAtIndex(source, 0, nil)
}
