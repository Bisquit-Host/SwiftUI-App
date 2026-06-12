enum AppAttestChallengeError: Error {
    case invalidResponse
    case serverError(String)
}
