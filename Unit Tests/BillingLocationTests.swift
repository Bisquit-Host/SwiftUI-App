import Foundation
import Testing

struct BillingLocationTests {
    @Test func `decodes service location ids as strings`() throws {
        let data = Data("""
        {
            "id": 1,
            "name": "Germany",
            "locations": ["1"],
            "portRange": ["25566-25800"],
            "remarks": [],
            "flagUrl": "https://flagcdn.com/96x72/de.webp",
            "enabled": true,
            "inStock": false
        }
        """.utf8)
        
        let location = try JSONDecoder().decode(ServiceLocation.self, from: data)
        
        #expect(location.locations == ["1"])
    }
}
