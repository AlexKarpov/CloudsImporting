//
//  File.swift
//  Importing
//
//  Created by Alexander Karpov on 30.10.2019.
//  Copyright © 2019 Alexander Karpov. All rights reserved.
//

import Extensions

public protocol File {
    var name: String { get }
    
    var isFolder: Bool { get }
    
    var path: String? { get }
}

extension File {
    public var `extension`: URL.FileType {
        URL.FileType(rawValue: path?.extension ?? "") ?? .unknown
    }
}
