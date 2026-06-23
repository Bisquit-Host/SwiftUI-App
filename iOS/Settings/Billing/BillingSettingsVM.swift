import Foundation
import BisquitoNet
import Calagopus
import OSLog

@Observable
final class BillingSettingsVM {
    var newName = ""
    var newEmail = ""
    var currentPassword = ""
    var newPassword = ""
    var confirmPassword = ""
    var isUpdatingPassword = false
    
    func changeName(onSuccess: @escaping () async -> Void) async {
        guard let accessToken = accessToken() else { return }
        
        if await changeNameAPI(
            newName: newName,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        ) != nil {
            newName = ""
            await onSuccess()
        }
    }
    
    func changeEmail() async {
        guard let accessToken = accessToken() else { return }
        
        if await changeEmailAPI(
            newEmail: newEmail,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        ) != nil {
            newEmail = ""
            SystemAlert.copied("Check your inbox")
        }
    }
    
    func changePassword(hasExistingPassword: Bool, onSuccess: @escaping () async -> Void) async {
        let trimmedCurrentPassword = currentPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if hasExistingPassword && trimmedCurrentPassword.isEmpty {
            SystemAlert.error("Enter current password")
            return
        }
        
        let trimmedNewPassword = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedNewPassword.isEmpty {
            SystemAlert.error("Enter new password")
            return
        }
        
        if trimmedNewPassword.count < 8 {
            SystemAlert.error("Password too short", subtitle: "Use at least 8 characters")
            return
        }
        
        if trimmedNewPassword.count > 70 {
            SystemAlert.error("Password too long", subtitle: "70 characters max")
            return
        }
        
        let trimmedConfirmation = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedNewPassword != trimmedConfirmation {
            SystemAlert.error("Passwords do not match")
            return
        }
        
        guard let accessToken = accessToken() else { return }
        
        isUpdatingPassword = true
        defer { isUpdatingPassword = false }
        
        if await changePasswordAPI(
            hasExistingPassword: hasExistingPassword,
            currentPassword: trimmedCurrentPassword,
            newPassword: trimmedNewPassword,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        ) != nil {
            resetPasswordFields()
            await onSuccess()
            SystemAlert.copied("Password updated")
        }
    }
    
    func resetPasswordFields() {
        currentPassword = ""
        newPassword = ""
        confirmPassword = ""
    }
    
    func updateAvatar(with data: Data, filename: String, mimeType: String?) async -> String? {
        guard let mimeType else {
            SystemAlert.error("Invalid mimetype")
            return nil
        }
        
        guard let accessToken = accessToken() else { return nil }
        
        let response = await updateAvatarAPI(
            data: data,
            filename: filename,
            mimeType: mimeType,
            accessToken: accessToken,
            onBillingError: SystemAlert.error
        )
        
        return response?.avatar
    }
}
