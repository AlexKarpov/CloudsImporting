////
////  DocumentPicker.swift
////  Importing
////
////  Created by Alexander Karpov on 09.12.2019.
////  Copyright © 2019 Alexander Karpov. All rights reserved.
////
//
//import UIKit
//import MobileCoreServices
//
//public class DocumentPicker: UIDocumentPickerViewController {
//    private var cancelationHandler: CancelationHandler?
//    
//    private var selectionHandler: SelectionHandler?
//    
//    private var progressHandler: ProgressHandler?
//    
//    private var completionHandler: DataHandler?
//    
//    let urlSession = URLSession.shared
//    
//    private var observation: NSKeyValueObservation?
//
//    deinit {
//      observation?.invalidate()
//    }
//    
//    public init() {
//        super.init(documentTypes: [kUTTypePDF as String], in: .import)
//        delegate = self
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
//}
//
//extension DocumentPicker: UIDocumentPickerDelegate {
//    enum Error: Swift.Error {
//        case missingData
//    }
//    
//    struct File: CloudsImporting.File {
//        var name: String
//        
//        var isFolder: Bool
//        
//        var path: String?
//    }
//    
//    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        downloadFile(at: urls[0])
//    }
//    
//    private func downloadFile(at url: URL) {
//        let file = File(name: url.lastPathComponent, isFolder: false, path: url.absoluteString)
//        selectionHandler?(file)
//        let task = urlSession.dataTask(with: url) { data, response, error in
//            if let error = error {
//                self.completionHandler?(.failure(error))
//            }
//            guard let data = data else {
//                self.completionHandler?(.failure(Error.missingData))
//                return
//            }
//            let result = DownloadResult(file, data)
//            self.completionHandler?(.success(result))
//        }
//        
//        observation = task.progress.observe(\.fractionCompleted) { [weak self] progress, _ in
//            self?.progressHandler?(progress)
//        }
//        
//        task.resume()
//    }
//    
//    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//        cancelationHandler?(())
//    }
//}
//
//extension DocumentPicker: PickerDelegate {
//    public func didSelect(_ selectionHandler: @escaping SelectionHandler) -> Self {
//        self.selectionHandler = selectionHandler
//        return self
//    }
//    
//    public func didCancel(_ cancelationHandler: @escaping CancelationHandler) -> Self {
//        self.cancelationHandler = cancelationHandler
//        return self
//    }
//}
//
//extension DocumentPicker: IDownloadRequest {
//    public func progress(_ progressHandler: @escaping ProgressHandler) -> Self {
//        self.progressHandler = progressHandler
//        return self
//    }
//    
//    public func response(_ completionHandler: DataHandler?) -> Self {
//        self.completionHandler = completionHandler
//        return self
//    }
//}
