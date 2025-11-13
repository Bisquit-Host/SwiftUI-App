import ScrechKit

@Observable
final class FolderPathVM {
    func copyFilePath(_ path: String, withHomeContainer: Bool) async {
        let string = "\(withHomeContainer ? "/home/container/" : "")\(path)"
        
        Pasteboard.copy(string)
        SystemAlert.copied()
    }
}
