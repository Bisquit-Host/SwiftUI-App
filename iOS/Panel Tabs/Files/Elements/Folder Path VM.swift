import ScrechKit

@Observable
final class FolderPathVM {
    func copyFilePath(_ path: String, withHomeContainer: Bool) async {
        let string = "\(withHomeContainer ? "/home/container/" : "")\(path)"
        
        UIPasteboard.general.string = string
        
        await SystemAlert.copied()
    }
}
