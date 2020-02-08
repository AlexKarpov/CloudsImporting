//
//  DownloadRequestMemory+DownloadRequest.swift
//  Importing
//
//  Created by Alexander Karpov on 30.10.2019.
//  Copyright © 2019 Alexander Karpov. All rights reserved.
//

import SwiftyDropbox

import Alamofire

public enum DownloadError: Swift.Error {
    case requestFaild(URL?, Swift.Error)
}

extension DownloadRequestMemory: IDownloadRequest where RSerial.ValueType: File, ESerial.ValueType: Swift.Error {
    public var url: URL? {
        request.request?.url
    }
    
    
    @discardableResult public func response(_ completionHandler: DataHandler?) -> Self {
        response { (response, error) in
            if let error = error {
                completionHandler?(.failure(.requestFaild(self.url, error)))
            }
            completionHandler?(.success(response))
        }
    }
}
