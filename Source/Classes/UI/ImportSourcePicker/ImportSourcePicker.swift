//
//  ImportSourcePicker.swift
//  CloudsImporting
//
//  Created by Alexander Karpov on 28.01.2020.
//  Copyright © 2020 Alexander Karpov. All rights reserved.
//

import UIKit
//import AlertsSDK
//import Extensions

final class ImportSourceCell: UICollectionViewCell {
    @IBOutlet weak var title: UILabel?
    
    @IBOutlet weak var icon: UIImageView?
    
    func configure(with service: Import.Strategy) {
        title?.text = service.name
        icon?.image = service.icon
    }
}

final class ImportSourcePicker: UICollectionViewController {
    typealias SelectionDelegate = Import.Strategy.SelectionDelegate
    
    static func content(selectionDelegate: SelectionDelegate? = nil) -> ImportSourcePicker? {
        let content = R.storyboard.importSourcePicker.instantiateInitialViewController()
        content?.selectionDelegate = selectionDelegate
        return content
    }
    
    private var selectionDelegate: SelectionDelegate?
    
    var services: [Import.Strategy] = Import.Strategy.allCases
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        services.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.importSourceCell, for: indexPath) else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        
        cell.configure(with: services[indexPath.row])
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true) {
            self.selectionDelegate?(self.services[indexPath.row])
        }
        
    }
}

extension UIAlertController {
    fileprivate typealias Content = ImportSourcePicker
    public static func importSourcePicker(sender: UIBarButtonItem? = nil, selectionDelegate: Import.Strategy.SelectionDelegate? = nil) -> UIAlertController {
        let dialog = UIAlertController(style: .actionSheet)
        dialog.popoverPresentationController?.barButtonItem = sender
        dialog.set(vc: Content.content(selectionDelegate: selectionDelegate))
        
        dialog.addAction(.cancel)
        return dialog
    }
}
