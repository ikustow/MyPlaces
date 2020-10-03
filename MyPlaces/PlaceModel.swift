//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Ilya on 01.10.2020.
//

import RealmSwift

class Place: Object {
  

    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
   
    let restaurantNames = [
       "Балкан Гриль", "Бочка", "Вкусные истории",
        "Дастархан", "Индокитай",
       "Классик", "Шок"
        ]
    
    func savePlaces(){
        for place in restaurantNames{
            
            let image = UIImage(named: place)
            
            guard let imageData = image?.pngData() else {return}
            let newPlace = Place()
            
            newPlace.name = place
            newPlace.location = "Moscow"
            newPlace.type = "Restaurant"
            newPlace.imageData = imageData
            StorageManager.saveObject(newPlace)
        
        }
    }
}
