import SwiftUI

struct FileListRedesign: View {
    var body: some View {
        ForEach(TaskItem.sample) {
            FileCardRedesign($0)
        }
    }
}

#Preview {
    FileListRedesign()
}
