//
//  Home.swift
//  mvvm_sandbox
//
//  Created by Omar Eduardo Gomez Padilla on 6/28/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import Foundation

struct Home: Decodable, Hashable, Equatable {
    
    struct Collection: Decodable, Hashable, Equatable {
        
        let code: String
        let thumb: String
        let title: String
        let thumb_featured: String
        let link: String
        let thumb_large: String
    }
    
    struct Link: Decodable, Hashable, Equatable {
        
        let json: String
        let html: String
    }
    
    struct Index: Decodable, Hashable, Equatable {
        
        let link: String
        let title: String
    }
    
    let featured: [Collection]
    let collections: [Collection]
    let links: Link?
    let indexes: [Index]
    
    init() {
        self.featured = []
        self.collections = []
        self.indexes = []
        self.links = nil
    }
}
