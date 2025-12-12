enum CloudProtectionProfileEditorMode {
    case create, edit(CloudProtectionProfile)
    
    var title: String {
        switch self {
        case .create: "New Profile"
        case .edit: "Edit Profile"
        }
    }
    
    var actionTitle: String {
        switch self {
        case .create: "Create profile"
        case .edit: "Save changes"
        }
    }
    
    var existingProfile: CloudProtectionProfile? {
        if case .edit(let profile) = self { return profile }
        return nil
    }
}
