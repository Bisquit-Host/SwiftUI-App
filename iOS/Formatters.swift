import Foundation

func millisecondsToTime(_ milliseconds: Int) -> String {
    let totalSeconds = milliseconds / 1000
    let days = totalSeconds / (24 * 3600)
    let hours = (totalSeconds % (24 * 3600)) / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    
    return String(format: "%dd %02d:%02d:%02d", days, hours, minutes, seconds)
}

func getImageUrl(_ imageName: String) -> URL {
    let stringUrl = "https://topscrech.dev/bisquit.host/assets/\(imageName).heic"
    
    guard let url = URL(string: stringUrl) else {
        fatalError("Failed to create URL from string: \(stringUrl)")
    }
    
    return url
}

func stringToUrl(_ string: String) -> URL? {
    URL(string: string)
}
