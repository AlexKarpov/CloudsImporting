//
//  CloudContentViewController.swift
//  CloudsImporting
//
//  Created by Alexander Karpov on 28.01.2020.
//  Copyright © 2020 Alexander Karpov. All rights reserved.
//


//protocol File {
//    var isFolder: Bool { get }
//
//    var title: String { get }
//
//    var id: String { get }
//
//    var `extension`: URL.FileType { get }
//}

import UIKit
import Extensions
//import Contracts

class FileRow: UITableViewCell {
    @IBOutlet weak var icon: UIImageView?
    
    @IBOutlet weak var title: UILabel?
    
    var file: CloudsImporting.File? {
        didSet {
            guard let file = file else { return }
            configure(for: file)
        }
    }
    
    func configure(for file: CloudsImporting.File) {
        icon?.image = file.isFolder ? R.image.folderIcon() : R.image.fileIcon()
        accessoryType = file.isFolder ? .disclosureIndicator : .none
        title?.text = file.name
    }
}

public protocol CloudContentViewControllerDelegate: AnyObject {
    func picker(_ picker: CloudContentViewController, didSelect requests: [IDownloadRequest])
}

final public class CloudContentViewController: UITableViewController {
    
    public typealias Delegate = CloudContentViewControllerDelegate
    
    public static func viewController(with strategy: Import.Strategy, delegate: Delegate?) -> UIViewController? {
        let navigation = R.storyboard.cloudContent.instantiateInitialViewController()
        let content = navigation?.root as? CloudContentViewController
        content?.service = strategy.proxy
        content?.delegate = delegate
        return navigation
    }
    
    var selectedFiles: [File] {
        tableView.indexPathsForSelectedRows?.compactMap { files[$0.row] } ?? []
    }
    
    var files: [File] = []
    
    var folder: File?
    
    weak var delegate: Delegate?
    
    private var service: IServiceProxy?
    
    public override func viewDidLoad() {
        service?.awake()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authorize()
    }
    
    private func authorize() {
        if service?.authState != .notAuthorized {
            self.getFiles()
            return
        }
        service?.authorize(on: self) { result in
            self.handle(result) { _ in
                self.getFiles()
            }
        }
    }
    
    private func receive(result: Result<[File], Error>) {
        handle(result) { files in
            self.files = files
            tableView.reloadData()
            tableView.endRefreshing()
        }
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        dismiss { [delegate, selectedFiles, service] in
            delegate?.picker(self, didSelect: selectedFiles.compactMap { service?.download($0) })
        }
    }
    
    @IBAction func getFiles(_ sender: UIRefreshControl? = nil) {
        guard service?.authState == .authorized else {
            print(service, "is not authorized")
            tableView.endRefreshing()
            return
        }
        service?.fetchFiles(for: folder?.path, callback: receive(result:))
    }
}

//MARK: - UITableViewDelegate

extension CloudContentViewController {
    override public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let file = files[indexPath.row]
        
        if file.isFolder { return indexPath }
        
        // file type validation
//        if file.extension == .unknown {
//            let supportedFormats = URL.FileType.allCases.dropLast().map{"."+$0.rawValue}.joined(separator: ", ")
//            self.showAlert(title: "Invalid file type", message: "Please select only \(supportedFormats) files for import", okButtonTitle: "Ok")
//            return nil
//        }
        
        return indexPath
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if files[indexPath.row].isFolder { return }
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
    }
    
    override public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if files[indexPath.row].isFolder { return }
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.destination, sender) {
        case (let content as CloudContentViewController, let cell as FileRow):
            content.folder = cell.file
            content.service = service
        default:
            break
        }
    }
    
    override public func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch (identifier, sender) {
        case (R.segue.cloudContentViewController.openFolder.identifier, let cell as FileRow):
            return cell.file?.isFolder ?? false
        default:
            return false
        }
    }
}

//MARK: - UITableViewDataSource

extension CloudContentViewController {

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        files.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let file = files[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.fileRow, for: indexPath) else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        cell.file = file
        
        //display checkmark if indexPath contained in selectedIndexPaths
        guard let selectedIndexPaths = tableView.indexPathsForSelectedRows else { return cell }
        let rowIsSelected = selectedIndexPaths.contains(indexPath)
        cell.accessoryType = rowIsSelected ? .checkmark : .none
        
        return cell
    }
}

