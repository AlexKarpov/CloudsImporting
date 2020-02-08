//
//  PickerDelegate.swift
//  Importing
//
//  Created by Alexander Karpov on 30.10.2019.
//  Copyright © 2019 Alexander Karpov. All rights reserved.
//

public protocol PickerDelegate {
    @discardableResult func didSelect(_ selectionHandler: @escaping SelectionHandler) -> Self
    
    @discardableResult func didCancel(_ cancelationHandler: @escaping CancelationHandler) -> Self
}
