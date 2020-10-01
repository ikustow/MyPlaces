//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Ilya on 01.10.2020.
//

import UIKit

struct Place {
    
    
    var name: String
    var location: String?
    var type: String?
    var image: UIImage?
    var restarauntImage: String?
    
    static let restaurantNames = [
       "Балкан Гриль", "Бочка", "Вкусные истории",
        "Дастархан", "Индокитай",
       "Классик", "Шок"
        ]
    
    static func getPlaces()->[Place]{
        var places = [Place]()
        
        for place in restaurantNames{
            
            places.append(Place(name: place, location: "Москва", type: "Ресторан", image: nil, restarauntImage:  place))
        }
        
        return places
    }
}
