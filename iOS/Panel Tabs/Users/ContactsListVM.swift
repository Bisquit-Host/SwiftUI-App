import Foundation
import Contacts
import OSLog

@Observable
final class ContactsListVM {
    private(set) var contacts: [ContactEmailSummary] = []
    var searchField = ""

    var filteredContacts: [ContactEmailSummary] {
        guard !searchField.isEmpty else { return contacts }

        return contacts.filter { contact in
            contact.fullName.localizedStandardContains(searchField)
                || contact.emailAddresses.contains { $0.localizedStandardContains(searchField) }
        }
    }

    func loadContactsWithEmail() async {
        do {
            let loadedContacts = try await Self.fetchContactsWithEmail()
            try Task.checkCancellation()
            contacts = loadedContacts
        } catch is CancellationError {
            return
        } catch {
            Logger().error("Failed to fetch contacts: \(error)")
        }
    }

    @concurrent
    private static func fetchContactsWithEmail() async throws -> [ContactEmailSummary] {
        try Task.checkCancellation()

        let store = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        var contacts: [ContactEmailSummary] = []

        try store.enumerateContacts(with: request) { contact, stop in
            guard !Task.isCancelled else {
                stop.pointee = true
                return
            }
            guard !contact.emailAddresses.isEmpty else { return }

            contacts.append(ContactEmailSummary(
                id: contact.identifier,
                fullName: [contact.givenName, contact.familyName]
                    .filter { !$0.isEmpty }
                    .joined(separator: " "),
                emailAddresses: contact.emailAddresses.map { $0.value as String }
            ))
        }

        try Task.checkCancellation()
        return contacts
    }
}
