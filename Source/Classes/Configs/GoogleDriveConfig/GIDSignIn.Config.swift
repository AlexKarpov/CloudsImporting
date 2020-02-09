//
//  GIDSignIn.Config.swift
//  Importing
//
//  Created by Alexander Karpov on 26.11.2019.
//  Copyright © 2019 Alexander Karpov. All rights reserved.
//

import GoogleSignIn

extension GIDSignIn {
    struct Config: Codable {
        let clientID: String
        
        init() {
            self = try! PropertyListDecoder().decode(
                Self.self,
                from: try! Data(contentsOf: R.file.googleDriveConfigPlist()!)
            )
        }
    }
}

extension GIDSignIn {
    static func awake(with config: GIDSignIn.Config = .init()) {
        GIDSignIn.sharedInstance()?.clientID = config.clientID
    }
}
