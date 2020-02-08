//
//  ErrorInterfaceConfirmations.swift
//  Importing
//
//  Created by Alexander Karpov on 30.10.2019.
//  Copyright © 2019 Alexander Karpov. All rights reserved.
//

import SwiftyDropbox

extension CallError: Error where EType: Error {}

extension SwiftyDropbox.Files.ListFolderError: Error {}

extension SwiftyDropbox.Files.SearchError: Error {}

extension SwiftyDropbox.Files.ListFolderContinueError: Error {}

extension SwiftyDropbox.Files.DownloadError: Error {}

extension OAuth2Error: Error {}
