import ScrechKit

@Observable
final class FolderPathVM {
    func copyFilePath(_ path: String, withHomeContainer: Bool) {
        UIPasteboard.general.string = "\(withHomeContainer ? "/home/container/" : "")\(path)"
        
        SystemAlert.copied()
    }
}
