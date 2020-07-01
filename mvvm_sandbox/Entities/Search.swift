//
//  Search.swift
//  mvvm_sandbox
//
//  Created by Omar Eduardo Gomez Padilla on 6/29/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import Foundation

struct Search: Decodable {
    
    struct Collection: Decodable {
        let title: String
    }
    
    struct Page: Decodable {
        let current: Int
        let total: Int
    }
    
    struct Image: Decodable {
        let alt: String
        let full: String
        let square: String
        let thumb: String
    }
    
    struct Result: Decodable, Hashable, Equatable {
        let index: Int
        let title: String
        let pk: String
        let image: Image
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(pk)
        }
        
        static func == (lhs: Result, rhs: Result) -> Bool {
            return lhs.pk == rhs.pk
        }
    }
    
    var results: [Result]
    var pages: Page
    var collection: Collection
}
