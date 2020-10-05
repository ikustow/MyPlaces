//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Ilya Kustov on 04/10/2020.
//  Copyright © 2020 Ilya Kustov. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deleteObject(_ place: Place) {
        
        try! realm.write {
            realm.delete(place)
        }
    }
}
