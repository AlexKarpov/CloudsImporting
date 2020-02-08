//
//  GoogleDriveProxy.swift
//  Importing
//
//  Created by Stas Lavruk on 22.11.2019.
//  Copyright © 2019 Alexander Karpov. All rights reserved.
//

import Foundation
//import Extensions
import Combine
import GoogleSignIn
import GTMSessionFetcher
import GoogleAPIClientForREST.GTLRDrive

class GoogleDriveProxy: BaseProxy, IServiceProxy {
    let service = GTLRDriveService()
    
    private var completionHandler: DataHandler?
    
    private var selectionHandler: SelectionHandler?
    
    private var progressHandler: ProgressHandler?
    
    private var resultDelegate: FetchResult?
    
    var cancelationHandler: CancelationHandler?
    var authDelegate: Block<Result<String, Error>, Void>?
    
    var name: String {
        "GoogleDrive"
    }
    
    var icon: UIImage {
        R.image.googleDiskIcon()
    }
    
    override init() {
        super.init()
        service.shouldFetchNextPages = true
    }
    
    func didCancel(_ cancelationHandler: @escaping CancelationHandler) -> Self {
        self.cancelationHandler = cancelationHandler
        return self
    }
    
    func awake() {
        GIDSignIn.awake()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeDriveReadonly]
    }
    
    
    func authorize(on vc: UIViewController, authDelegate: @escaping Block<Result<String, Error>, Void>) {
        authState = .inProgress
        self.authDelegate = authDelegate
        if GIDSignIn.sharedInstance()?.hasPreviousSignIn() ?? false {
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
            return
        }
        GIDSignIn.sharedInstance()?.presentingViewController = vc
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func handle(redirect url: URL?) {
        guard let url = url else { return }
        guard (GIDSignIn.sharedInstance()?.handle(url)) != nil else { return }
    }
    
    func fetchFiles(for path: String?, callback: @escaping FetchResult) {}
    
    func searchFiles(for path: String, callback: @escaping FetchResult) {
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "mimeType='application/pdf'"
        query.fields = "files(size, name, id)"
        service.executeQuery(query) { (ticket, results, error) in
            let fileList = (results as? GTLRDrive_FileList)?.files
            if let error = error {
                callback(.failure(error))
                return
            }
            callback(.success(fileList ?? []))
        }
    }
    
    func download(_ file: File) -> IDownloadRequest? {
        selectionHandler?(file)
        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: file.path!)
        let downloadRequest = service.request(for: query) as URLRequest
        let fetcher = service.fetcherService.fetcher(with: downloadRequest)
        return DownloadRequest.init { request in
            let progress = Progress(totalUnitCount: (file as? GTLRDrive_File)?.size?.int64Value ?? NSURLSessionTransferSizeUnknown)
            fetcher.receivedProgressBlock = { bytesWritten, totalBytesWritten in
                progress.completedUnitCount = totalBytesWritten
                request.progressHandler?(progress)
            }
            fetcher.beginFetch { (data, error) in
                if let error = error {
                    request.dataHandler?(.failure(.requestFaild(downloadRequest.url, error)))
                }
                request.dataHandler?(.success(DownloadResult(file: file, data!)))
            }
        }
        .response(completionHandler)
        .progress(progressHandler ?? handle)
    }
    
    private func handle(_ progress: Progress) {
        print(progress)
    }
    
    func progress(_ progressHandler: @escaping ProgressHandler) -> Self {
        self.progressHandler = progressHandler
        return self
    }
    
    func response(_ completionHandler: DataHandler?) -> Self {
        self.completionHandler = completionHandler
        return self
    }
    
    func didSelect(_ selectionHandler: @escaping Block<File, Void>) -> Self {
        self.selectionHandler = selectionHandler
        return self
    }
}



extension GTLRDrive_File: File {
    public var name: String {
        value(forKey: "name") as? String ?? ""
    }
    
    public var isFolder: Bool {
        false
    }
    
    public var path: String? {
        identifier!
    }
    
}
