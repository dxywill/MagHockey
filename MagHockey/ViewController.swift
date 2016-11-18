//
//  ViewController.swift
//  MagHockey
//
//  Created by Xinyi Ding on 11/17/16.
//  Copyright © 2016 Xinyi. All rights reserved.
//

import UIKit
import CoreMotion


class ViewController: UIViewController {
    
    var magnetX = 0.000
    var magnetY = 0.000
    var magnetZ = 0.000
    
    var motionManager = CMMotionManager()
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        motionManager.startMagnetometerUpdates()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.getData), userInfo: nil, repeats: true)
        self.getData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getData() {
        if let magnetometerData = motionManager.magnetometerData {
            print("X " + String(magnetometerData.magneticField.x))
            print("Y " + String(magnetometerData.magneticField.y))
            print("Z " + String(magnetometerData.magneticField.z))
        }
    }
}

