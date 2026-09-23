#if os(iOS)
import SwiftUI
import PhotosUI
import OSLog

extension FileTabVM {
    func handleFileImportResult(_ result: Result<[URL], Error>, at root: String) async {
        switch result {
        case .success(let urls):
            let accessedURLs = urls.filter { $0.startAccessingSecurityScopedResource() }
            defer {
                accessedURLs.forEach { $0.stopAccessingSecurityScopedResource() }
            }

            await handleFileImport(urls, at: root)

        case .failure(let error):
            Logger().error("File import failed: \(error)")
        }
    }

    func handlePhotoImport(_ items: [PhotosPickerItem], at root: String) async {
        var temporaryURLs: [URL] = []
        defer { UploadTemporaryFile.remove(temporaryURLs) }

        for item in items {
            guard !Task.isCancelled else { return }
            guard let pathExtension = item.supportedContentTypes.compactMap(\.preferredFilenameExtension).first else {
                Logger().error("Unable to determine photo library file extension")
                continue
            }

            do {
                guard let data = try await item.loadTransferable(type: Data.self) else { continue }
                try Task.checkCancellation()
                let url = try UploadTemporaryFile.write(data, pathExtension: pathExtension)
                temporaryURLs.append(url)
            } catch is CancellationError {
                return
            } catch {
                Logger().error("Unable to prepare photo library item: \(error)")
            }
        }

        guard !Task.isCancelled, !temporaryURLs.isEmpty else { return }
        await handleFileImport(temporaryURLs, at: root)
    }
}
#endif
