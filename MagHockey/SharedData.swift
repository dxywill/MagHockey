//
//  SharedData.swift
//  MagHockey
//
//  Created by Xinyi Ding on 11/27/16.
//  Copyright © 2016 Xinyi. All rights reserved.
//


class SharedData {
    
    static let sharedInstance = SharedData()
    
    var coordinateX = 0.0
    var coordinateY = 0.0
    
    
    func updateCoordiante(with x: Double, and y: Double) {
        coordinateX = x
        coordinateY = y
        print("updated")
        print(coordinateX)
        print(coordinateY)
    }
    
    func getCoordinates() -> (x: Double, y: Double) {
        return (coordinateX, coordinateY)
    }
}
