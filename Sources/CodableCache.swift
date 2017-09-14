//
//  CodableCache.swift
//  CodableCache
// 
//  Created by Andrew Sowers on 9/10/17.
//  Copyright © 2017 CodableCache. All rights reserved.
//

import Foundation

public struct CodableCache<T: Codable> {
    
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    
    let memoryCache: NSCache<AnyObject, AnyObject>
    let persistentCache: PersistentCache<T>
    
    let key: AnyHashable
    
    public init(key: AnyHashable, encoder: JSONEncoder = JSONEncoder(), decoder: JSONDecoder = JSONDecoder()) {
        self.key = key
        self.memoryCache = NSCache<AnyObject, AnyObject>()
        self.persistentCache = PersistentCache<T>(key: key, encoder: encoder, decoder: decoder)
        self.encoder = encoder
        self.decoder = decoder
    }
    
    
}

// MARK - Filemanager helpers

extension CodableCache {
    public func filePathForKey(_ key: AnyHashable) -> String {
        return self.persistentCache.filePathForKey(key)
    }
}

// MARK: - Cacher operations
extension CodableCache {
    
    public func get() throws -> T {
        if let data = self.memoryCache.object(forKey: self.key.hashValue as AnyObject) as? Data {
            return try decoder.decode(T.self, from: data)
        } else {
            return try self.persistentCache.get(self.key)
        }
    }
    
    public func set(value: T) throws {
        let archivedValue = try! encoder.encode(value)
        self.memoryCache.setObject(archivedValue as AnyObject, forKey: self.key.hashValue as AnyObject)
        try self.persistentCache.set(value, forKey: self.key)
    }
    
    public func clear() {
        self.memoryCache.removeAllObjects()
        self.persistentCache.clear()
    }
    
    
}
