//
//  Typealiases.swift
//  Importing
//
//  Created by Alexander Karpov on 30.10.2019.
//  Copyright © 2019 Alexander Karpov. All rights reserved.
//

public typealias FetchResult = (Swift.Result<[File], Error>) -> Void

public typealias Block<Response, Result> = (Response) -> Result

public typealias StringResult = Swift.Result<String, Error>

public typealias ProgressHandler = Block<Progress, Void>

//public typealias DataHandler = Block<Data, Void>

public typealias DataHandler = (Swift.Result<DownloadResult?, DownloadError>) -> Void

public typealias SelectionHandler = Block<File, Void>

public typealias CancelationHandler = Block<Void, Void>

public typealias Files = [File]

public typealias DownloadResult = (file: File, data: Data)
