//
//  BoxConfig.swift
//  Importing
//
//  Created by Alexander Karpov on 28.01.2020.
//  Copyright © 2020 Alexander Karpov. All rights reserved.
//

import BoxSDK

struct Config: Codable {
    let clientId: String
    let clientSecret: String
    
    init() {
        self = try! PropertyListDecoder().decode(
            Self.self,
            from: try! Data(contentsOf: R.file.boxConfigPlist()!)
        )
    }
}


extension BoxSDK {
    convenience init(_ config: Config = .init()) {
        self.init(
            clientId: config.clientId,
            clientSecret: config.clientSecret
        )
    }
}
