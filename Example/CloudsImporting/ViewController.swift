//
//  ViewController.swift
//  CloudsImporting
//
//  Created by Alexander Karpov on 02/07/2020.
//  Copyright (c) 2020 Alexander Karpov. All rights reserved.
//

import UIKit
import CloudsImporting

class ViewController: UITableViewController {
    
    var pendingImports: [IDownloadRequest] = []
    var downloadedFiles: [File] = []
    
}

//MARK: - Importing logic

extension ViewController: CloudContentViewController.Delegate {
    func picker(_ picker: CloudContentViewController, didSelect requests: [IDownloadRequest]) {
        pendingImports.insert(contentsOf: requests, at: 0)
        let indexPaths = requests.enumerated().map { pair -> IndexPath in
            pair.element.handleData(at: self)
            return IndexPath(row: pair.offset, section: 0)
        }
        tableView?.insertRows(at: indexPaths, with: .automatic)
    }
    
    func didFinishImporting(_ file: File) {
        #warning("handle file")
        print(file)
    }
 
    func didSelectImport(_ strategy: Import.Strategy) {
        try? present(
            CloudContentViewController.viewController(
                with: strategy,
                delegate: self
            )
        )
    }
    
    @IBAction func toggleImport(_ sender: UIBarButtonItem? = nil) {
        present(
            UIAlertController.importSourcePicker(
                sender: navigationItem.leftBarButtonItem,
                selectionDelegate: didSelectImport
            )
        )
    }
}

extension ViewController: IFileDownloadHandler {
    func requestDidComplete(with result: Result<DownloadResult?, DownloadError>) {
        print(result)
    }
}

