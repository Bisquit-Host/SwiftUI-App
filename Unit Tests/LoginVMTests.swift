import Foundation
import Testing
import BisquitoNet

@testable import Bisquit_Host

@MainActor
struct LoginVMTests {
    @Test func `sign in accepts usernames without signup validation`() {
        let vm = LoginVM()
        vm.loginInput = "  username  "
        vm.password = "password"

        #expect(!vm.continueButtonDisabled)
        #expect(vm.emailValidationError == nil)
    }

    @Test func `signup requires valid email name and document acceptance`() {
        let vm = LoginVM()
        vm.isSignUp = true
        vm.loginInput = "person@example.com"
        vm.password = "password"
        #expect(vm.continueButtonDisabled)

        vm.name = "Person"
        #expect(vm.continueButtonDisabled)

        vm.hasAcceptedDocuments = true
        #expect(!vm.continueButtonDisabled)

        vm.loginInput = "invalid-email"
        #expect(vm.continueButtonDisabled)
        #expect(vm.emailValidationError != nil)

        vm.loginInput = " \nperson+tag@example.com\n "
        #expect(!vm.continueButtonDisabled)
        #expect(vm.emailValidationError == nil)

        vm.isSignUp = false
        #expect(!vm.hasAcceptedDocuments)
    }

    @Test func `blank credentials and attestation prevent submission`() {
        let vm = LoginVM()
        vm.loginInput = " \n "
        vm.password = "password"
        #expect(vm.continueButtonDisabled)

        vm.loginInput = "person@example.com"
        vm.password = "   "
        #expect(vm.continueButtonDisabled)

        vm.password = "password"
        vm.isAttesting = true
        #expect(vm.continueButtonDisabled)
    }

    @Test func `Apple sign in preserves provider through two factor verification`() throws {
        let vm = LoginVM()
        vm.twoFACode = "123456"
        let challenge = try JSONDecoder().decode(
            BillingSessionAuthResponse.self,
            from: Data(#"{"twoFa":true,"token":"challenge"}"#.utf8)
        )
        vm.handleOAuthResponse(challenge)

        #expect(vm.sheet2FA)
        #expect(vm.pending2FAToken == "challenge")
        #expect(vm.twoFACode.isEmpty)
        #expect(vm.sessionToken == nil)
        #expect(vm.completedOAuthProvider == nil)

        let success = try JSONDecoder().decode(
            BillingSessionAuthResponse.self,
            from: Data(#"{"sessionToken":"test-session"}"#.utf8)
        )
        vm.handleAuthResponse(success)

        #expect(!vm.sheet2FA)
        #expect(vm.pending2FAToken == nil)
        #expect(vm.sessionToken == "test-session")
        #expect(vm.completedOAuthProvider == .apple)
        #expect(!vm.completedPasskeyLogin)
    }

    @Test func `passkey success clears a pending OAuth provider`() throws {
        let vm = LoginVM()
        let challenge = try JSONDecoder().decode(
            BillingSessionAuthResponse.self,
            from: Data(#"{"twoFa":true,"token":"challenge"}"#.utf8)
        )
        vm.handleOAuthResponse(challenge)

        let success = try JSONDecoder().decode(
            BillingSessionAuthResponse.self,
            from: Data(#"{"sessionToken":"test-session"}"#.utf8)
        )
        vm.handlePasskeyResponse(success)

        #expect(vm.sessionToken == "test-session")
        #expect(vm.completedPasskeyLogin)
        #expect(vm.completedOAuthProvider == nil)
        #expect(!vm.sheet2FA)
    }

    @Test func `passkey is recorded only after two factor verification succeeds`() throws {
        let vm = LoginVM()
        let challenge = try JSONDecoder().decode(
            BillingSessionAuthResponse.self,
            from: Data(#"{"twoFa":true,"token":"challenge"}"#.utf8)
        )
        vm.handlePasskeyResponse(challenge)

        #expect(vm.sheet2FA)
        #expect(vm.sessionToken == nil)
        #expect(!vm.completedPasskeyLogin)

        let success = try JSONDecoder().decode(
            BillingSessionAuthResponse.self,
            from: Data(#"{"sessionToken":"test-session"}"#.utf8)
        )
        vm.handleAuthResponse(success)

        #expect(vm.completedPasskeyLogin)
        #expect(vm.completedOAuthProvider == nil)
        #expect(vm.sessionToken == "test-session")
    }

}
