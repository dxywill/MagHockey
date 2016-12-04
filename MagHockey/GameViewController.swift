//
//  GameViewController.swift
//  MagHockey
//
//  Created by Xinyi Ding on 11/26/16.
//  Copyright © 2016 Xinyi. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion

class GameViewController: UIViewController {
    
    let model = SharedData.sharedInstance
    
    var locationTimer: Timer!
    var magnetX = 0.000
    var magnetY = 0.000
    var magnetZ = 0.000
    let dsid = 99

    var motionManager = CMMotionManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        
        motionManager.startMagnetometerUpdates()
        
        locationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameViewController.getLocation), userInfo: nil, repeats: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    func getLocation() {
        
        if let magnetometerData = motionManager.magnetometerData {
            print(String(magnetometerData.magneticField.x) + " " + String(magnetometerData.magneticField.y) + " " + String(magnetometerData.magneticField.z))
            
            magnetX = magnetometerData.magneticField.x
            magnetY = magnetometerData.magneticField.y
            magnetZ = magnetometerData.magneticField.z
        }
        
        
        
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        
        guard let URL = URL(string: "http://192.168.0.6:8000/PredictOne") else {return}
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        
        // Headers
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        // JSON Body
        
        let bodyObject = [
            "dsid": dsid,
            "features": [magnetX - model.caliMagnetX, magnetY - model.caliMagnetY, magnetZ - model.caliMagnetZ]
            ] as [String : Any]
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        
        /* Start a new Task */
        let task = session.dataTask(with: request) {
            
            (data: Data?, response: URLResponse?, error: Error?) in
            
            if (error == nil) {
                // Success
                //let statusCode = (response as! HTTPURLResponse).statusCode
                //print("URL Session Task Succeeded: HTTP \(statusCode)")
                
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Double]
                    //print(parsedData)
                    self.model.updateCoordiante(with: parsedData["x"]!, and: parsedData["y"]!)
                } catch let error as NSError {
                    print(error)
                }
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
        }
        task.resume()
        session.finishTasksAndInvalidate()
    }
}
