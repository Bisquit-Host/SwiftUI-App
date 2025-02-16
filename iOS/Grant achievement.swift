import GameKit

func grantAchievement(_ id: String) {
    let achievement = GKAchievement(identifier: id)
    achievement.percentComplete = 100
    achievement.showsCompletionBanner = true
    
    GKAchievement.report([achievement]) { error in
        if let error {
            print("Error granting achievement: \(error.localizedDescription)")
        } else {
            print("Achievement granted: \(id)")
        }
    }
}
