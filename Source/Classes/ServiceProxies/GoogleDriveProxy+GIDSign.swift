//
//  GoogleDriveProxy+GIDSign.swift
//  Importing
//
//  Created by Alexander Karpov on 26.11.2019.
//  Copyright © 2019 Alexander Karpov. All rights reserved.
//

import GoogleSignIn

extension GoogleDriveProxy: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.canceled.rawValue {
                cancelationHandler?(())
                authState = .canceled
                return
            }
            authState = .failure
            authDelegate?(.failure(error))
            return
        }
        authState = .authorized
        service.authorizer = user.authentication.fetcherAuthorizer()
        authDelegate?(.success(signIn.clientID))
    }
}
