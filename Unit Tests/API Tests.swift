import XCTest

final class PteroNetTests: XCTestCase {
    //    func testListStartupVariables() {
    //        let expectation = self.expectation(description: "API-keys fetched")
    //
    //        twoFaDetailtsAPI(printResponse: true) { result in
    //            switch result {
    //            case .success(let vm):
    //                if let model {
    //                    print(model)
    //                }
    //
    //                expectation.fulfill()
    //
    //            case .failure(let error):
    //                print(error.localizedDescription)
    //                XCTFail("Error")
    //            }
    //        }
    //
    //        waitForExpectations(timeout: 10, handler: nil)
    //    }
    //
    //    func testTwoFaDetailtsAPI() {
    //        let expectation = self.expectation(description: "API-keys fetched")
    //
    //        twoFaDetailtsAPI(printResponse: true) { result in
    //            switch result {
    //            case .success(let model):
    //                if let model {
    //                    print(model)
    //                }
    //
    //                expectation.fulfill()
    //
    //            case .failure(let error):
    //                print(error.localizedDescription)
    //                XCTFail("Error")
    //            }
    //        }
    //
    //        waitForExpectations(timeout: 10, handler: nil)
    //    }
    //
    //    func testPermissionList() {
    //        let expectation = self.expectation(description: "API-keys fetched")
    //        permissionListAPI(printResponse: false) { result in
    //            switch result {
    //            case .success(let model):
    //                print("Success")
    //                if let model {
    //                    print(model)
    //                }
    //
    //                expectation.fulfill()
    //
    //            case .failure:
    //                XCTFail("Error")
    //            }
    //        }
    //        waitForExpectations(timeout: 10, handler: nil)
    //    }
    //
    //    //    func testSample() {
    //    //        if let json = readJSONFromFile("Log Attributes") {
    //    //            print(json)
    //    //        } else {
    //    //            print("Failed to read or process JSON")
    //    //        }
    //    //    }
    //
    //    func testFileList() {
    //        PteroNet_Defaults.apiKey = Config.debugApiKey
    //
    //        measure {
    //            let expectation = self.expectation(description: "API-keys fetched")
    //            getFileListAPI("2fb25a50", from: "") { result in
    //                switch result {
    //                case .success:
    //                    print("Success")
    //                    expectation.fulfill()
    //
    //                case .failure:
    //                    print("Success")
    //                    XCTFail("Error")
    //                }
    //            }
    //            waitForExpectations(timeout: 10, handler: nil)
    //        }
    //    }
    //
    //    func testSendCommand() {
    //        let expectation = self.expectation(description: "API-keys fetched")
    //
    //        PteroNet_Defaults.apiKey = Config.debugApiKey
    //
    //        sendCommandAPI (
    //            "2fb25a50",
    //            command: "PteroNet Test"
    //        ) { result in
    //            switch result {
    //            case .success(let model):
    //                expectation.fulfill()
    //
    //                print("Model: \(model)")
    //
    //            case .failure(let error):
    //                print("Error: \(error.localizedDescription)")
    //
    //                XCTFail("Error: \(error.localizedDescription)")
    //            }
    //        }
    //
    //        waitForExpectations(timeout: 10, handler: nil)
    //    }
    //
    //    func testGetLogs() {
    //        let expectation = self.expectation(description: "API-keys fetched")
    //
    //        PteroNet_Defaults.apiKey = Config.debugApiKey
    //
    //        getLogsAPI("2fb25a50", printResponse: true) { result in
    //            switch result {
    //            case .success(let model):
    //                if let model {
    //                    print(model)
    //                }
    //
    //                expectation.fulfill()
    //
    //            case .failure(let error):
    //                XCTFail("Error: \(error.localizedDescription)")
    //            }
    //        }
    //
    //        waitForExpectations(timeout: 10, handler: nil)
    //    }
    //
    //    func testAccountDetails() {
    //        let expectation = self.expectation(description: "API-keys fetched")
    //
    //        PteroNet_Defaults.apiKey = Config.debugApiKey
    //
    //        accountDetailsAPI(printResponse: true) { result in
    //            switch result {
    //            case .success:
    //                expectation.fulfill()
    //
    //            case .failure(let error):
    //                XCTFail("Error: \(error.localizedDescription)")
    //            }
    //        }
    //
    //        waitForExpectations(timeout: 10, handler: nil)
    //    }
    //
    //    func testGetServerDetails() {
    //        let expectation = self.expectation(description: "API-keys fetched")
    //
    //        PteroNet_Defaults.apiKey = Config.debugApiKey
    //
    //        serverDetailsAPI("2fb25a50", printResponse: true) { result in
    //            switch result {
    //            case .success:
    //                expectation.fulfill()
    //
    //            case .failure(let error):
    //                XCTFail("Error: \(error.localizedDescription)")
    //            }
    //        }
    //
    //        waitForExpectations(timeout: 10, handler: nil)
    //    }
    //
    //    func testGetApiKeyList() {
    //        let expectation = self.expectation(description: "API-keys fetched")
    //
    //        PteroNet_Defaults.apiKey = Config.debugApiKey
    //
    //        getApiKeyList(printResponse: true) { result in
    //            switch result {
    //            case .success:
    //                expectation.fulfill()
    //
    //            case .failure(let error):
    //                XCTFail("Error: \(error.localizedDescription)")
    //            }
    //        }
    //
    //        waitForExpectations(timeout: 10, handler: nil)
    //    }
    //
    //    func testGetUsers() {
    //        PteroNet_Defaults.apiKey = Config.debugApiKey
    //        guard let request = URLRequest(
    //            path: "client/servers/4e400cc0/users"
    //        ) else {
    //    return
    //}
    //
    //        let expectation = self.expectation(description: "Network Request")
    //
    //        URLSession.shared.dataTask(with: request) { data, response, error in
    //            defer {
    //                expectation.fulfill()
    //            }
    //
    //            if let error {
    //                print(error.localizedDescription)
    //                return
    //            }
    //
    //            guard let data else {
    //                print("No data received")
    //                return
    //            }
    //
    //            if let jsonString = String(data: data, encoding: .utf8) {
    //                print(jsonString)
    //            } else {
    //                print("Cannot convert data to String")
    //            }
    //        }.resume()
    //
    //        waitForExpectations(timeout: 10, handler: nil)
    //    }
}
