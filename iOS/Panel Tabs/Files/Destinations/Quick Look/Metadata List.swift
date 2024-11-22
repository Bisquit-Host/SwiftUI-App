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
                    
                    Text("\(value)")
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
        case .localizedNameKey: "Localized Name"
        case .localizedTypeDescriptionKey: "Localized Type Description"
        case .creationDateKey: "Created"
        case .contentModificationDateKey: "Modified"
        case .attributeModificationDateKey: "Attribute Modification Date"
        case .contentAccessDateKey: "Last opened"
        case .isHiddenKey: "Is Hidden"
        case .isReadableKey: "Is Readable"
        case .isWritableKey: "Is Writable"
        case .isExecutableKey: "Is Executable"
        case .fileSizeKey: "File Size"
        case .fileAllocatedSizeKey: "File Allocated Size"
        case .totalFileSizeKey: "Total File Size"
        case .totalFileAllocatedSizeKey: "Total File Allocated Size"
        case .preferredIOBlockSizeKey: "Preferred IO Block Size"
        case .typeIdentifierKey: "Type Identifier"
        case .contentTypeKey: "Content Type"
        case .generationIdentifierKey: "Generation Identifier"
        case .documentIdentifierKey: "Document Identifier"
        case .fileIdentifierKey: "File Identifier"
        case .isDirectoryKey: "Is Directory"
        case .isRegularFileKey: "Is Regular File"
        case .isSymbolicLinkKey: "Is Symbolic Link"
        case .isSystemImmutableKey: "Is System Immutable"
        case .isUserImmutableKey: "Is User Immutable"
        case .isExcludedFromBackupKey: "Is Excluded from Backup"
        case .isAliasFileKey: "Is Alias File"
        case .isPackageKey: "Is Package"
        case .linkCountKey: "Link Count"
        case .labelColorKey: "Label Color"
        case .labelNumberKey: "Label Number"
        default: "Unknown Key"
        }
    }
}
