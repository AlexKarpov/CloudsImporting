//
//  SwiftyDropbox.Files.Metadata+File.swift
//  Importing
//
//  Created by Alexander Karpov on 30.10.2019.
//  Copyright © 2019 Alexander Karpov. All rights reserved.
//

import SwiftyDropbox

extension SwiftyDropbox.Files.Metadata: File {
    public var isFolder: Bool {
        self is SwiftyDropbox.Files.FolderMetadata
    }
    
    public var path: String? {
        pathLower
    }
}
