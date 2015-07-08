//
//  NSURLRequest+PhoneId.swift
//  PhoneIdSDK
//
//  Created by Alyona on 6/23/15.
//  Copyright © 2015 phoneId. All rights reserved.
//

import Foundation


extension NSURLRequest{

    class func requestWithURL(URL: NSURL, method: String, queryParams: [String: String]?, bodyParams: Dictionary<String,AnyObject>?, headers: [String: String]?) -> NSURLRequest {
    
        let actualURL: NSURL
        if let queryParams = queryParams {

            var query:String=""
            for contentKey in queryParams.keys {
                if(contentKey == queryParams.keys.first) {
                    query += contentKey + "=" + (queryParams[contentKey]! as String).escapeStr()
                }
                else {
                    query += "&" + contentKey + "=" + (queryParams[contentKey]! as String).escapeStr()
                }
            }
            let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true)!
            components.percentEncodedQuery = query
            NSLog("query = %@", query)
            actualURL = components.URL!
        } else {
            actualURL = URL
        }
        
        NSLog("URL = %@", actualURL.absoluteString)
        
        let request = NSMutableURLRequest(URL: actualURL)
        request.HTTPMethod = method
        
        if let bodyParams = bodyParams, let headers = headers {
            
            if headers[HttpHeaderName.ContentType]==HttpHeaderValue.JsonEncoded {
                 do {
                     request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(bodyParams, options: [])
                 } catch _ {
                     request.HTTPBody = nil
                 }
            } else if headers[HttpHeaderName.ContentType]==HttpHeaderValue.FormEncoded{
                
                var firstOneAdded = false
                let contentKeys:Array<String> = Array(bodyParams.keys)
                var contentBodyAsString:String=""
                for contentKey in contentKeys {
                    if(!firstOneAdded) {
                        contentBodyAsString += contentKey + "=" + (bodyParams[contentKey]! as! String).escapeStr()
                        firstOneAdded = true
                    }
                    else {
                        contentBodyAsString += "&" + contentKey + "=" + (bodyParams[contentKey]! as! String).escapeStr()
                    }
                }
                request.HTTPBody = contentBodyAsString.dataUsingEncoding(NSUTF8StringEncoding)!
                
            }
            

        }
        
        if let headers = headers {
            for (field, value) in headers {
                request.setValue(value, forHTTPHeaderField: field)
            }
        }
        
        return request
    }


}

extension String {
    func escapeStr() -> (String) {
        let raw: NSString = self
        let allowedCharacters = NSCharacterSet.URLHostAllowedCharacterSet().mutableCopy();
        allowedCharacters.removeCharactersInString(":?&=;+!@#$()',*");
        let str = raw.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters as! NSCharacterSet)
        return str!
    }
}
