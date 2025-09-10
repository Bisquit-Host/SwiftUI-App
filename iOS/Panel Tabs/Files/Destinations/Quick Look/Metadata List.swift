import SwiftUI

struct MetadataList: View {
    private let metadata: [URLResourceKey: Any]?
    
    init(_ metadata: [URLResourceKey : Any]?) {
        self.metadata = metadata
    }
    
    var body: some View {
        if let metadata {
            let sorted = metadata.sorted {
                $0.key.rawValue < $1.key.rawValue
            }
            
            List(sorted, id: \.key) { key, value in
                HStack {
                    Text(key.loc)
                        .headline()
                    
                    Spacer()
                    
                    Text(String(describing: value))
                        .secondary()
                }
            }
        } else {
            ContentUnavailableView("No metadata available", systemImage: "exclamationmark.triangle")
        }
    }
}

fileprivate extension URLResourceKey {
    var loc: LocalizedStringResource {
        switch self {
        case .nameKey: "Name"
        case .localizedNameKey: "Localized name"
        case .localizedTypeDescriptionKey: "Localized type description"
        case .creationDateKey: "Created"
        case .contentModificationDateKey: "Modified"
        case .attributeModificationDateKey: "Attribute modification date"
        case .contentAccessDateKey: "Last opened"
        case .isHiddenKey: "Is hidden"
        case .isReadableKey: "Is readable"
        case .isWritableKey: "Is writable"
        case .isExecutableKey: "Is executable"
        case .fileSizeKey: "File size"
        case .fileAllocatedSizeKey: "File allocated size"
        case .totalFileSizeKey: "Total file size"
        case .totalFileAllocatedSizeKey: "Total file allocated size"
        case .preferredIOBlockSizeKey: "Preferred IO block size"
        case .typeIdentifierKey: "Type identifier"
        case .contentTypeKey: "Content type"
        case .generationIdentifierKey: "Generation identifier"
        case .documentIdentifierKey: "Document identifier"
        case .fileIdentifierKey: "File identifier"
        case .isDirectoryKey: "Is directory"
        case .isRegularFileKey: "Is regular file"
        case .isSymbolicLinkKey: "Is symbolic link"
        case .isSystemImmutableKey: "Is system immutable"
        case .isUserImmutableKey: "Is user immutable"
        case .isExcludedFromBackupKey: "Is excluded from backup"
        case .isAliasFileKey: "Is alias file"
        case .isPackageKey: "Is package"
        case .linkCountKey: "Link count"
        case .labelColorKey: "Label color"
        case .labelNumberKey: "Label number"
        default: "Unknown key"
        }
    }
}
