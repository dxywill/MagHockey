//
//  TrainViewController.swift
//  MagHockey
//
//  Created by Xinyi Ding on 11/26/16.
//  Copyright © 2016 Xinyi. All rights reserved.
//

import UIKit
import CoreMotion


class TrainViewController: UIViewController {
    
    let dsid = 201
    let host = "http://10.8.122.45:8000"
    let model = SharedData.sharedInstance
    var magnetX = 0.000
    var magnetY = 0.000
    var magnetZ = 0.000
    
    var motionManager = CMMotionManager()
    var timer: Timer!
    
    var xCoordinate = 0
    var yCoordinate = 0
    let bufferLength = 10
    var magArray = [[Double]]()
    var magXLabels = [Double]()
    var magYLabels = [Double]()
    
    var origMagnetX = 0.000
    var origMagnetY = 0.000
    var origMagnetZ = 0.000
    
    
    
    
    
    @IBOutlet weak var xValue: UILabel!
    @IBOutlet weak var yValue: UILabel!
    
    @IBOutlet weak var stepXOutlet: UIStepper!
    
    @IBOutlet weak var stepYOutlet: UIStepper!
    
    @IBAction func xStepper(_ sender: UIStepper) {
        xValue.text = String(sender.value)
    }
    @IBAction func yStepper(_ sender: UIStepper) {
        yValue.text = String(sender.value)
    }

    @IBAction func dataSwitch(_ sender: UISwitch) {

    }
    
    @IBOutlet weak var caliSwitch: UISwitch!
    
    @IBAction func sendData(_ sender: UIButton) {
        sendFeatures()
    }
    
    @IBAction func getPredict(_ sender: UIButton) {
        getPredictOne()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        motionManager.startMagnetometerUpdates()
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(TrainViewController.getData), userInfo: nil, repeats: true)
        //locationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TrainViewController.getPredictOne), userInfo: nil, repeats: true)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getData() {
        if let magnetometerData = motionManager.magnetometerData {
            print(String(magnetometerData.magneticField.x) + " " + String(magnetometerData.magneticField.y) + " " + String(magnetometerData.magneticField.z))
            
           
            magnetX = magnetometerData.magneticField.x
            magnetY = magnetometerData.magneticField.y
            magnetZ = magnetometerData.magneticField.z
            
            if caliSwitch.isOn {
                origMagnetX = magnetometerData.magneticField.x
                origMagnetY = magnetometerData.magneticField.y
                origMagnetZ = magnetometerData.magneticField.z
                model.updateOrig(with: origMagnetX, and: origMagnetY, and: origMagnetZ)
            }
            
             let feature = [magnetometerData.magneticField.x - origMagnetX , magnetometerData.magneticField.y - origMagnetY, magnetometerData.magneticField.z - origMagnetZ]
            
            //Fill features
            if magArray.count >= bufferLength {
                magArray.remove(at: 0)
                magArray.append(feature)
            } else {
                magArray.append(feature)
            }
            
            //Fill labels
            if magXLabels.count >= bufferLength {
                magXLabels.remove(at: 0)
                magXLabels.append(stepXOutlet.value)
            } else {
                magXLabels.append(stepXOutlet.value)
            }
            
            if magYLabels.count >= bufferLength {
                magYLabels.remove(at: 0)
                magYLabels.append(stepYOutlet.value)
            } else {
                magYLabels.append(stepYOutlet.value)
            }
        }
    }

    func sendFeatures() {
        
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        
        guard let URL = URL(string: host + "/AddDataPoint") else {return}
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        
        // Headers
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        // JSON Body
        
        let bodyObject = [
            "dsid": dsid,
            "status": magXLabels,
            "features": magArray
            ] as [String : Any]
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        
        /* Start a new Task */
        let task = session.dataTask(with: request) {
            
            (data: Data?, response: URLResponse?, error: Error?) in
            
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                print(error)
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
        }
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func getPredictOne() {
        
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a NSURLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        
        guard let URL = URL(string: host + "/PredictOne") else {return}
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        
        // Headers
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        // JSON Body
        
        let bodyObject = [
            "dsid": dsid,
            "features": [magnetX - origMagnetX, magnetY - origMagnetY, magnetZ - origMagnetZ]
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
                    //self.model.updateCoordiante(with: parsedData["x"]!, and: parsedData["y"]!)
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
