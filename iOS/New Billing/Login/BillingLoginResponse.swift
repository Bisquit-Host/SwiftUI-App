public struct BillingLoginResponse: Decodable {
    /// Pass to the Authorization header.
    /// Expires in 15m
    let accessToken: String
    
    /// Used to get a new accessToken.
    /// Also gets updated
    let refreshToken: String
    
    /// milliseconds
    let expiresIn: Int
}
