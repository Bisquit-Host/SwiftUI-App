import SwiftUI

struct BillingPasskeysView: View {
    @State private var vm = BillingPasskeysVM()

    var body: some View {
        List {
            Section("Register new passkey") {
                TextField("Label (optional)", text: $vm.label)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)

                Button {
                    Task { await vm.registerPasskey() }
                } label: {
                    if vm.isRegistering {
                        HStack {
                            ProgressView()
                            Text("Creating passkey...")
                        }
                    } else {
                        Text("Create passkey")
                    }
                }
                .disabled(vm.isRegistering)
            }

            Section("Your passkeys") {
                if vm.passkeys.isEmpty && !vm.isLoading {
                    ContentUnavailableView("No passkeys yet", systemImage: "key.fill", description: Text("Register a passkey to sign in without a password."))
                        .listRowBackground(Color.clear)
                }

                ForEach(vm.passkeys) { passkey in
                    BillingPasskeyRow(passkey: passkey)
                        .swipeActions {
                            Button(role: .destructive) {
                                Task { await vm.deletePasskey(passkey) }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .navigationTitle("Passkeys")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await vm.fetchPasskeys()
        }
        .task {
            await vm.fetchPasskeys()
        }
        .overlay {
            if vm.isLoading {
                ProgressView("Loading passkeys...")
            }
        }
        .alert("Passkey error", isPresented: Binding(get: {
            vm.error != nil
        }, set: { newValue in
            if !newValue {
                vm.error = nil
            }
        })) {
            Button("OK", role: .cancel) {
                vm.error = nil
            }
        } message: {
            if let error = vm.error {
                Text(error)
            }
        }
    }
}

private struct BillingPasskeyRow: View {
    let passkey: PasskeyListItem

    private let isoFormatter = ISO8601DateFormatter()
    private let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "key.fill")
                    .foregroundStyle(.blue)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(passkey.nickname.flatMap { $0.isEmpty ? nil : $0 } ?? "Passkey #\(passkey.id)")
                        .subheadline(.semibold)

                    if let createdText = formattedDate(passkey.createdAt) {
                        Text("Created \(createdText)")
                            .footnote()
                            .foregroundStyle(.secondary)
                    }

                    if let lastUsed = formattedDate(passkey.lastUsedAt) {
                        Text("Last used \(lastUsed)")
                            .footnote()
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if passkey.userVerified {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.yellow)
                }
            }

            HStack(spacing: 8) {
                if passkey.backedUp {
                    Label("Synced", systemImage: "cloud.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if !passkey.transports.isEmpty {
                    Label(passkey.transports.joined(separator: ", "), systemImage: "bolt.horizontal.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }

    private func formattedDate(_ value: String?) -> String? {
        guard let value, let date = isoFormatter.date(from: value) else {
            return nil
        }

        return relativeFormatter.localizedString(for: date, relativeTo: .init())
    }
}

#Preview {
    NavigationStack {
        BillingPasskeysView()
    }
    .environmentObject(ValueStore())
    .darkSchemePreferred()
}
