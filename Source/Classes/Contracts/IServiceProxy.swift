//
//  IServiceProxy.swift
//  Importing
//
//  Created by Alexander Karpov on 30.10.2019.
//  Copyright © 2019 Alexander Karpov. All rights reserved.
//

import UIKit

public enum AuthState {
    case notAuthorized, inProgress, authorized, canceled, failure
}

public protocol IServiceProxy: AnyObject, PickerDelegate {
    var name: String { get }
    
    var icon: UIImage { get }
    
    var authState: AuthState { get }
    
    func awake()
    
    func authorize(on vc: UIViewController, authDelegate: @escaping Block<Result<String, Error>, Void>)
    
    func handle(redirect url: URL?)
    
    //fetch files for specified path, pass nill for root folder
    func fetchFiles(for path: String?, callback: @escaping FetchResult)
    
    func searchFiles(for path: String, callback: @escaping FetchResult)
    
    @discardableResult func download(_ file: File) -> IDownloadRequest?
}
