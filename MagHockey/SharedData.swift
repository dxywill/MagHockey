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
    var caliMagnetX = 0.0
    var caliMagnetY = 0.0
    var caliMagnetZ = 0.0
    
    
    func updateCoordiante(with x: Double, and y: Double) {
        coordinateX = x
        coordinateY = y
    }
    
    func updateOrig(with x: Double, and y: Double, and z: Double) {
        caliMagnetX = x
        caliMagnetY = y
        caliMagnetZ = z
    }
    
    func getOrigs() -> (x: Double, y: Double, z: Double) {
        return (caliMagnetX, caliMagnetY, caliMagnetZ)
    }
    
    func getCoordinates() -> (x: Double, y: Double) {
        return (coordinateX, coordinateY)
    }
}
