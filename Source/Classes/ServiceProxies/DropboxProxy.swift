//
//  DropboxProxy.swift
//  Importing
//
//  Created by Alexander Karpov on 30.10.2019.
//  Copyright © 2019 Alexander Karpov. All rights reserved.
//

import SwiftyDropbox
//import Extensions
import Combine

fileprivate extension String {
    static var root: String {
        ""
    }
}

@available(iOS 13, *)
extension Set where Element: AnyCancellable {
    func cancel(){}
}

class BaseProxy: NSObject {
    var authState: AuthState = .notAuthorized
    
    private var _subscriptions: Set<AnyHashable> = []
    
    @available(iOS 13, *)
    private var subscriptions: Set<AnyCancellable> {
        get {
            _subscriptions as! Set<AnyCancellable>
        }
        set {
            _subscriptions = newValue
        }
    }
    
    override init() {
        super.init()
        if #available(iOS 13.0, *) {
            NotificationCenter.default
                .publisher(for: .sceneOpenURLContexts).sink(receiveValue: handle)
                .store(in: &subscriptions)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(handle(notification:)), name: .sceneOpenURLContexts, object: nil)
        }
    }
    
    deinit {
        if #available(iOS 13.0, *) {
            subscriptions.cancel()
        } else {
            NotificationCenter.default.removeObserver(self)
        }
        print(self, "dealocated")
    }
    
    @objc private func handle(notification: Notification) {
        guard let handler = self as? IServiceProxy else { return }
        switch notification.object {
        case let set as Set<AnyHashable>:
            guard #available(iOS 13.0, *), let contexts = set as? Set<UIOpenURLContext>, let url = contexts.first?.url else { return }
            handler.handle(redirect: url)
        case let url as URL:
            handler.handle(redirect: url)
        default:
            break
        }
    }
}

final class DropboxProxy: BaseProxy, IServiceProxy {
    private var progressHandler: ProgressHandler?
    
    private var completionHandler: DataHandler?
    
    private var selectionHandler: SelectionHandler?
    
    private var cancelationHandler: CancelationHandler?
    
    private var authDelegate: Block<StringResult, Void>?
    
    func didSelect(_ selectionHandler: @escaping SelectionHandler) -> Self {
        self.selectionHandler = selectionHandler
        return self
    }
    
    func progress(_ progressHandler: @escaping ProgressHandler) -> Self {
        self.progressHandler = progressHandler
        return self
    }
    
    func response(_ completionHandler: DataHandler?) -> Self {
        self.completionHandler = completionHandler
        return self
    }
    
    func didCancel(_ cancelationHandler: @escaping CancelationHandler) -> Self {
        self.cancelationHandler = cancelationHandler
        return self
    }
    
    var name: String {
        "Dropbox"
    }
    
    var icon: UIImage {
        R.image.dropBoxIcon()!
    }
    
    func handle(redirect url: URL?) {
        guard let url = url else { return }
        guard let authResult = DropboxClientsManager.handleRedirectURL(url) else { return }
        switch authResult {
        case .success(let token):
            authState = .authorized
            authDelegate?(.success(token.accessToken))
            print("Success! User is logged into Dropbox with token: \(token)")
        case .cancel:
            print("User canceld OAuth flow.")
            authState = .canceled
            cancelationHandler?(())
        case .error(let error, let description):
            authState = .failure
            authDelegate?(.failure(error as Error))
            print("Error \(error): \(description)")
        }
    }
    
    func awake() {
        guard DropboxOAuthManager.sharedOAuthManager == nil else { return }
        DropboxClientsManager.awake()
    }
    
    func authorize(on vc: UIViewController, authDelegate: @escaping Block<Result<String, Error>, Void>) {
        authState = .inProgress
        if let token = DropboxClientsManager.authorizedClient?.auth.client.accessToken {
            authState = .authorized
            authDelegate(.success(token))
            return
        }
        self.authDelegate = authDelegate
        
        DropboxClientsManager.authorizeFromController(.shared, controller: vc) { url in
            UIApplication.shared.open(url)
        }
    }
    
    var resultDelegate: FetchResult?
    
    func fetchFiles(for path: String?, callback: @escaping FetchResult) {
        resultDelegate = callback
        DropboxClientsManager
            .authorizedClient?
            .files
            .listFolder(path: path ?? .root)
            .response(completionHandler: handle)
    }
    
    func searchFiles(for path: String, callback: @escaping FetchResult) {
        resultDelegate = callback
        DropboxClientsManager
            .authorizedClient?
            .files
            .search(path: path, query: ".pdf")
            .response(completionHandler: handle)
    }
    
    func download(_ file: File) -> IDownloadRequest? {
        selectionHandler?(file)
        return DropboxClientsManager
            .authorizedClient?
            .files
            .download(path: file.path!)
            .progress(progressHandler ?? handle)
            .response(completionHandler ?? handle)
    }
    
    private func handle(_ progress: Progress) {
        print(progress)
    }
    
    private func handle(_ result: Result<DownloadResult?, DownloadError>) {
        print(result)
    }
    
    private func handle(_ result: SwiftyDropbox.Files.SearchResult?, _ error: Error?) {
        if let error = error {
            resultDelegate?(.failure(error))
        } else if let result = result {
            resultDelegate?(.success(result.matches.map { $0.metadata }))
            guard  result.more else { return }
            #warning("search parammeters is hardcoded need to find solution for passing parrameters from general search request: searchFiles(for path: String, callback: @escaping FetchResult)")
            DropboxClientsManager
                .authorizedClient?
                .files
                .search(path: "", query: ".pdf", start: result.start)
                .response(completionHandler: handle)
        }
    }
    
    private func handle(_ result: SwiftyDropbox.Files.ListFolderResult?, _ error: Error?) {
        if let error = error {
            resultDelegate?(.failure(error))
        } else if let result = result {
            resultDelegate?(.success(result.entries))
            guard  result.hasMore else { return }
            DropboxClientsManager
                .authorizedClient?
                .files
                .listFolderContinue(cursor: result.cursor)
                .response(completionHandler: handle)
        }
    }
}
