//
//  FileLink.swift
//  Bisquit.Host
//
//  Created by Sergei Saliukov on 13.05.2025.
//  Copyright © 2025 Bisquit.Host. All rights reserved.
//


struct FileLink: Codable, Hashable {
    let id: String
    let name: String
    let root: String
    
    init(_ id: String, name: String, at root: String) {
        self.id = id
        self.name = name
        self.root = root
    }
}
