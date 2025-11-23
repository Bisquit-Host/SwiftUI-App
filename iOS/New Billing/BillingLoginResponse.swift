struct BillingLoginResponse: Decodable {
    /// Authorization header
    let accessToken: String
    
    /// Used to get a new accessToken.
    /// Also gets updated
    let refreshToken: String
    
    /// seconds
    let expiresIn: Int
}
