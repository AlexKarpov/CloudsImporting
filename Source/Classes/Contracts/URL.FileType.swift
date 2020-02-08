//
//  URL.FileType.swift
//  CloudsImporting
//
//  Created by Alexander Karpov on 07.02.2020.
//

import Foundation

public extension URL {
    enum FileType: String, CaseIterable {
        case pdf, rtf, txt, docx, unknown
    }
}
