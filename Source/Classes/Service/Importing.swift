//
//  Importing.swift
//  Importing
//
//  Created by Alexander Karpov on 25.10.2019.
//  Copyright © 2019 Alexander Karpov. All rights reserved.
//

import UIKit

public class Import {
    let service: IServiceProxy
    
    public enum Strategy: CaseIterable {
        public typealias SelectionDelegate = (Strategy) -> Void
        
        case dropbox, google, box
        
        var proxy: IServiceProxy {
            switch self {
            case .dropbox:
                return DropboxProxy()
            case .google:
                return GoogleDriveProxy()
            case .box:
                return BoxProxy()
            }
        }
        
        public var name: String {
            proxy.name
        }
        
        public var icon: UIImage {
            proxy.icon
        }
    }
    
    @available(iOS 13.0, *)
    public static func handle(authorization context: Set<UIOpenURLContext>) {
        NotificationCenter.default.post(name: .sceneOpenURLContexts, object: context)
    }
    
    public static func handle(authorization url: URL) {
        NotificationCenter.default.post(name: .sceneOpenURLContexts, object: url)
    }
    
    init(_ strategy: Strategy) {
        service = strategy.proxy
    }
    
    deinit {
        print(self, "dealocated")
    }
}

extension NSNotification.Name {
    static let sceneOpenURLContexts: NSNotification.Name = .init("sceneOpenURLContexts")
}
