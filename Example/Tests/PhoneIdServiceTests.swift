//
//  PhoneIdSDKTests.swift
//  PhoneIdSDKTests
//
//  Created by Alyona on 6/22/15.
//  Copyright © 2015 phoneId. All rights reserved.
//

import XCTest

@testable import phoneid_iOS

class PhoneIdServiceTests: XCTestCase {
    
    // MARK: loadClients
    
    func testGetClients_Success() {
        
        let session = MockUtil.sessionForMockResponseWithParams(Endpoints.ClientsList.endpoint(TestConstants.ClientId),params: ["appName":"SomeCoolName"], statusCode:200)
        let phoneId:PhoneIdService = PhoneIdService()
        phoneId.urlSession = session
        phoneId.clientId = TestConstants.ClientId
        
        let expectation = expectationWithDescription("Should successfully handle request clients list")
        expectationForNotification(Notifications.UpdateAppName, object: nil, handler: nil)
        
        phoneId.loadClients(phoneId.clientId! ) { (e) -> Void in
            if(e == nil){
                expectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
        
        XCTAssertNotNil(phoneId.appName, "phoneId.appName can't be nill after succesfull call loadClients")
        XCTAssertEqual(phoneId.appName!, "SomeCoolName")
        
    }
    
    func testGetClients_UnexpectedResponse() {
        let session = MockUtil.sessionForMockResponseWithParams(Endpoints.ClientsList.endpoint(TestConstants.ClientId),params: ["unexpected":"SomeCoolName"], statusCode:200)
        let phoneId:PhoneIdService = PhoneIdService()
        phoneId.urlSession = session
        phoneId.clientId = TestConstants.ClientId
        
        let expectation = expectationWithDescription("Expected fail to parse response")
        var error:NSError?=nil
        phoneId.loadClients(phoneId.clientId! ) { (e) -> Void in
            
            if let e = e{
                error = e
                e.print()
                expectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
        XCTAssertNotNil(error, "error can't be nil when unexpected content received")
        
    }
    
    func testGetClients_ErrorResponse() {
        let session = MockUtil.sessionForMockResponseWithParams(Endpoints.ClientsList.endpoint(TestConstants.ClientId),params: [], statusCode:500)
        let phoneId:PhoneIdService = PhoneIdService()
        phoneId.urlSession = session
        phoneId.clientId = TestConstants.ClientId
        
        let expectation = expectationWithDescription("Expected to get server error")
        var error:NSError?=nil
        phoneId.loadClients(phoneId.clientId! ) { (e) -> Void in
            
            if let e = e{
                error = e
                e.print()
                expectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
        XCTAssertNotNil(error, "error can't be nil when server returns error")
        
    }
    
    // MARK: requestAuthentication
    func testRequestAuthentication_Success() {
        
        let session = MockUtil.sessionForMockResponseWithParams(Endpoints.RequestCode.endpoint(),params: ["result":0,"message":"Message Sent"], statusCode:200)
        let phoneId:PhoneIdService = PhoneIdService()
        phoneId.urlSession = session
        phoneId.clientId = TestConstants.ClientId
        
        let expectation = expectationWithDescription("Expected successful request for authentication")
        let numberInfo = TestConstants.numberInfo
        phoneId.requestAuthenticationCode(numberInfo) { (error) -> Void in
            if(error == nil){
                expectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
        
    }
    
    func testRequestAuthentication_UnexpectedResponse() {
        
        let session = MockUtil.sessionForMockResponseWithParams(Endpoints.RequestCode.endpoint(),params:["result":188,"message":":-P"], statusCode:200)
        let phoneId:PhoneIdService = PhoneIdService()
        phoneId.urlSession = session
        phoneId.clientId = TestConstants.ClientId
        
        let expectation = expectationWithDescription("Expected fail parse of response")
        let numberInfo = TestConstants.numberInfo
        var error:NSError?=nil
        phoneId.requestAuthenticationCode(numberInfo) { (e) -> Void in
            if let e = e{
                error = e
                e.print()
                expectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
        XCTAssertNotNil(error, "error can't be nil when unexpected content received")
    }
    
    func testRequestAuthentication_ErrorResponse() {
        let session = MockUtil.sessionForMockResponseWithParams(Endpoints.RequestCode.endpoint(),params:[], statusCode:500)
        let phoneId:PhoneIdService = PhoneIdService()
        phoneId.urlSession = session
        phoneId.clientId = TestConstants.ClientId
        
        let expectation = expectationWithDescription("Expected request fail")
        let numberInfo = TestConstants.numberInfo
        var error:NSError?=nil
        
        phoneId.requestAuthenticationCode(numberInfo) { (e) -> Void in
            if let e = e{
                error = e
                e.print()
                expectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
        XCTAssertNotNil(error, "error can't be nil when server returns error")
    }
    
    // MARK: verifyAuthentication
    
    func testVerifyAuthentication_Success() {
        let accessToken = "ea99fa1f6a7c7713dbcc7d94edfdbc48b15c47a0"
        let refreshToken = "5023784657d3549ad4887c3d313d42bab83106b6"
        let expires = 3600
        let session = MockUtil.sessionForMockResponseWithParams(Endpoints.RequestCode.endpoint(),
            params:["token_type":"bearer", "access_token":accessToken, "expires_in":expires,"refresh_token":refreshToken], statusCode:200)
        
        let phoneId:PhoneIdService = PhoneIdService()
        phoneId.urlSession = session
        phoneId.clientId = TestConstants.ClientId
        
        
        let expectation = expectationWithDescription("Should successfully handle request for verification code confirmation")
        expectationForNotification(Notifications.LoginSuccess, object: nil, handler: nil)
        
        var result:TokenInfo?
        phoneId.verifyAuthentication(TestConstants.VerificationCode, info: TestConstants.numberInfo) { (token, error) -> Void in
            if(error == nil){
                result = token
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
        
        XCTAssertNotNil(result, "Expected non nil token")
        XCTAssertTrue(result!.isValid(), "Expected valid token")
        XCTAssertEqual(accessToken, result!.accessToken!)
        XCTAssertNotNil(phoneId.token, "Expected non nil phoneId.token")
        XCTAssertEqual(phoneId.token!.accessToken!, result!.accessToken!)
        XCTAssertEqual(refreshToken, result!.refreshToken!)
        XCTAssertEqual(expires, result!.expirationPeriod!)
        
    }
    
    func testVerifyAuthentication_ErrorResponse_Normal() {
        
        let message = "Invalid code"
        let session = MockUtil.sessionForMockResponseWithParams(Endpoints.RequestCode.endpoint(),
            params:["code":"InvalidContent","message":message], statusCode:400)
        
        let phoneId:PhoneIdService = PhoneIdService()
        phoneId.urlSession = session
        phoneId.clientId = TestConstants.ClientId
        
        
        let expectation = expectationWithDescription("Should return legal error when wrong verification code provided")
        expectationForNotification(Notifications.LoginFail, object: nil, handler: nil)
        
        var result:TokenInfo?
        var errorResult:NSError?
        phoneId.verifyAuthentication(TestConstants.VerificationCode, info: TestConstants.numberInfo) { (token, error) -> Void in
            errorResult = error
            result = token
            if(error != nil){
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
        
        XCTAssertNil(result, "Expected nil token")
        XCTAssertNotNil(errorResult, "Expected non nil error")
        XCTAssertEqual(errorResult!.localizedFailureReason!, message)
    }
    
    func testVerifyAuthentication_ErrorResponse_Abnormal() {
        
        let session = MockUtil.sessionForMockResponseWithParams(Endpoints.RequestCode.endpoint(), params:[:], statusCode:500)
        
        let phoneId:PhoneIdService = PhoneIdService()
        phoneId.urlSession = session
        phoneId.clientId = TestConstants.ClientId
        
        
        let expectation = expectationWithDescription("Should return default error  when server fails to prcess request")
        expectationForNotification(Notifications.LoginFail, object: nil, handler: nil)
        
        var result:TokenInfo?
        var errorResult:NSError?
        phoneId.verifyAuthentication(TestConstants.VerificationCode, info: TestConstants.numberInfo) { (token, error) -> Void in
            
            errorResult = error
            result = token
            if(error != nil){
                error?.print()
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
        
        XCTAssertNil(result, "Expected nil token")
        XCTAssertNotNil(errorResult, "Expected non nil error")
        
    }
    
    func testVerifyAuthentication_InvalidTokenInfo() {
        
        let refreshToken = "5023784657d3549ad4887c3d313d42bab83106b6"
        let session = MockUtil.sessionForMockResponseWithParams(Endpoints.RequestCode.endpoint(),
            params:["token_type":"bearer", "refresh_token":refreshToken], statusCode:200)
        
        let phoneId:PhoneIdService = PhoneIdService()
        phoneId.urlSession = session
        phoneId.clientId = TestConstants.ClientId
        
        
        let expectation = expectationWithDescription("Should fail when received incomplete token info")
        expectationForNotification(Notifications.LoginFail, object: nil, handler: nil)
        
        var result:TokenInfo?
        var errorResult:NSError?
        phoneId.verifyAuthentication(TestConstants.VerificationCode, info: TestConstants.numberInfo) { (token, error) -> Void in
            result = token
            errorResult = error
            if(error != nil){
                error?.print()
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
        
        XCTAssertNil(result, "Expected nil token")
        XCTAssertNotNil(errorResult, "Expected non nil error")
        
    }
    
    // MARK: loadtUserInfo
    
    func testLoadUserInfo_Success() {
        let userInfo = ["client_id":TestConstants.ClientId, "phone_number":TestConstants.PhoneNumber, "id":"5592d5d308ca480c644249ea"]
        
        let session = MockUtil.sessionForMockResponseWithParams(Endpoints.RequestMe.endpoint(),params:userInfo, statusCode:200)
        let phoneId:PhoneIdService = PhoneIdService()
        phoneId.urlSession = session
        phoneId.clientId = TestConstants.ClientId
        
        let expectation = expectationWithDescription("Should successfully handle user info request")

        var result:UserInfo? = nil
        phoneId.loadUserInfo { (userInfo, e) -> Void in
            
            result = userInfo
            if(e == nil){
                expectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
        
        XCTAssertNotNil(result, "User info should not be nil for successfull request")
        XCTAssertTrue(result!.isValid(), "User info expected to be valid for succesfull request")
        XCTAssertEqual(result!.clientId!, TestConstants.ClientId)
        XCTAssertEqual(result!.phoneNumber!, TestConstants.PhoneNumber)
        XCTAssertEqual(result!.id!, "5592d5d308ca480c644249ea")
        
    }
    
    func testLoadUserInfo_ErrorResponse() {

        let session = MockUtil.sessionForMockResponseWithParams(Endpoints.RequestMe.endpoint(),params:[:], statusCode:401)
        let phoneId:PhoneIdService = PhoneIdService()
        phoneId.urlSession = session
        phoneId.clientId = TestConstants.ClientId
        
        let expectation = expectationWithDescription("Expected to get server error")
        
        var result:UserInfo? = nil
        var errorResult:NSError?
        phoneId.loadUserInfo { (userInfo, e) -> Void in
            
            result = userInfo
            if(e != nil){
                errorResult = e
                errorResult?.print()
                expectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
        
        XCTAssertNil(result, "Expected nil userInfo")
        XCTAssertNotNil(errorResult, "Expected non nil error")
    
    }
    
    func testLoadUserInfo_UnexpectedResponse() {
        
        let session = MockUtil.sessionForMockResponseWithParams(Endpoints.RequestMe.endpoint(),params:[], statusCode:200)
        let phoneId:PhoneIdService = PhoneIdService()
        phoneId.urlSession = session
        phoneId.clientId = TestConstants.ClientId
        
        let expectation = expectationWithDescription("Expected to get server error")

        var errorResult:NSError?
        phoneId.loadUserInfo { (userInfo, e) -> Void in

            if(e != nil){
                errorResult = e
                errorResult?.print()
                expectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(TestConstants.defaultStepTimeout, handler: nil)
 
        XCTAssertNotNil(errorResult, "Expected non nil error")
        
    }
    
}