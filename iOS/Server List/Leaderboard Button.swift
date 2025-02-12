import SwiftUI
import GameKit

struct LeaderboardButton: View {
    var body: some View {
        Button {
            showLeaderboard()
        } label: {
            Label("Leaderboards", systemImage: "trophy")
        }
    }
    
    private func showLeaderboard() {
#if !os(macOS) && !os(watchOS)
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootVC = windowScene.keyWindow?.rootViewController
        else {
            return
        }
        
        let gcVC = GKGameCenterViewController(
            leaderboardID: "owned_servers",
            playerScope: .global,
            timeScope: .allTime
        )
        gcVC.gameCenterDelegate = GameCenterDelegate.shared
        rootVC.present(gcVC, animated: true)
#endif
    }
}

#if !os(macOS) && !os(watchOS)
// MARK: - Fix: Proper Game Center Delegate
class GameCenterDelegate: NSObject, GKGameCenterControllerDelegate {
    static let shared = GameCenterDelegate()
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}

fileprivate extension UIWindowScene {
    var keyWindow: UIWindow? {
        windows.first { $0.isKeyWindow }
    }
}
#endif
