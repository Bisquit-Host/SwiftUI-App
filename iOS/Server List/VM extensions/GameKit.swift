import GameKit

extension ServerListVM {
    func submitScore() async {
        guard !ValueStore().adminServerList else {
            return
        }
        
        let score = self.servers.filter(\.serverOwner).count
        
        do {
            try await GKLeaderboard.submitScore(
                score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: ["owned_servers"]
            )
            
            print("Score submitted", score)
        } catch {
            print("Failed to submit score:", error.localizedDescription)
        }
    }
}
