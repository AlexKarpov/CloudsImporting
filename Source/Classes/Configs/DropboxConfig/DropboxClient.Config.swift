//
//  DropboxClient.Config.swift
//  Importing
//
//  Created by Alexander Karpov on 30.10.2019.
//  Copyright © 2019 Alexander Karpov. All rights reserved.
//

import SwiftyDropbox

extension DropboxClient {
    struct Config: Codable {
        let apiKey: String
        
        init() {
            let configPath = Bundle.main.url(forResource: "DropboxConfig", withExtension: "plist")!
            self = try! PropertyListDecoder().decode(
                Self.self,
                from: try! Data(contentsOf: configPath)
            )
        }
    }
}

extension DropboxClientsManager {
    static func awake(with config: DropboxClient.Config = .init()) {
        setupWithAppKey(config.apiKey)
    }
}
