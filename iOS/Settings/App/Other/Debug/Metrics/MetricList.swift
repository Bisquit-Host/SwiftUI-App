import SwiftUI
import QuickLook

struct MetricList: View {
    @State private var vm = MetricListVM()
    @State private var previewURL: URL?
    
    var body: some View {
        List {
            if vm.files.isEmpty {
                Text("No metrics saved yet")
                    .secondary()
            } else {
                ForEach(vm.filesByDay(), id: \.day) { day, urls in
                    Section {
                        ForEach(urls, id: \.self) { url in
                            Button {
                                previewURL = url
                            } label: {
                                MetricCard(url)
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        Text(day, style: .date)
                    }
                }
            }
        }
        .navigationTitle("Metrics")
        .quickLookPreview($previewURL)
        .refreshableTask {
            vm.loadFiles()
        }
    }
}
