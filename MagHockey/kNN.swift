//
//  kNN.swift
//  a simple kNN Implementation based on Surge
//
//  Created by Xinyi Ding on 12/10/16.
//  Copyright © 2016 Xinyi. All rights reserved.
//

import Surge

class kNN: NSObject {
    var features:[Matrix<Double>] = []
    var labels: [Int] = []
    var mu = [Matrix<Double>](repeating: Matrix<Double>([[0, 0, 0]]), count: 21)
    var sigma =  [Matrix<Double>](repeating: Matrix<Double>([[0, 0, 0], [0, 0, 0], [0, 0, 0]]), count: 21)
    var k = 3
    var fNum = 0
    var perClassCount = [Double](repeating: 0, count: 21)
    
    func addFeatures(feature: [Double]) {
//        let matrix : Matrix<Double> = Matrix<Double>([feature])
//        features.append(matrix)
        let str = "\(feature[0]) \(feature[1]) \(feature[2]) \n"
        let filePath = getDocumentsDirectory().appendingPathComponent("features.txt")
        writeToCSV(fileName: filePath, row: str)
    }
    
    func addLabel(label: Int) {
//        labels.append(label)
        let str = "\(label) \n"
        let filePath = getDocumentsDirectory().appendingPathComponent("labels.txt")
        writeToCSV(fileName: filePath, row: str)
    }
    
    func train() {
        print("Start Training")
        let path = getDocumentsDirectory().appendingPathComponent("features.txt")
        
        do {
            let data = try String(contentsOfFile: path, encoding: .utf8)
            let strFeatures = data.components(separatedBy: .newlines)
            for str in strFeatures {
                 if !str.isEmpty {
                    var doubleFeatures =  str.components(separatedBy: " ")
                    let feature: [Double] = [Double(doubleFeatures[0])!, Double(doubleFeatures[1])!, Double(doubleFeatures[2])!]
                    let matrix : Matrix<Double> = Matrix<Double>([feature])
                    features.append(matrix)
                }
            }
        } catch {
            print(error)
        }
        
        let labelPath = getDocumentsDirectory().appendingPathComponent("labels.txt")
        
        do {
            let data = try String(contentsOfFile: labelPath, encoding: .utf8)
            let strFeatures = data.components(separatedBy: .newlines)
            for str in strFeatures {
                if !str.isEmpty {
                    var intLabels =  str.components(separatedBy: " ")
                    let l = Int(intLabels[0])!
                    labels.append(l)
                }
            }
        } catch {
            print(error)
        }
        print(features.count)
        print(labels.count)
        
        self.fNum = labels.count
        //Calculate Mean for each class
        for i in 0..<self.fNum {
            let cl = self.labels[i]
            self.perClassCount[cl] += 1
            mu[cl] = Surge.add(mu[cl], y: features[i])
        }
        for i in 0..<21 {
            mu[i] = Matrix<Double>( [mu[i][row: 0] / perClassCount[i]]) //Suge does not support matrix div by element
        }
        //Calculate Covariance matrix for each class
        for i in 0..<self.fNum {
            let cl = self.labels[i]
            let matrixDiff = matrixSub(x: features[i], y: mu[cl])
            let matrixDiffT = Surge.transpose(matrixDiff)
            let tmpSigma = Surge.mul(matrixDiffT, y:matrixDiff)
            
            sigma[cl] = Surge.add(sigma[cl], y: tmpSigma)
        }
        
        for i in 0..<21 {
            sigma[i] = matrixDiv(x: sigma[i], y: perClassCount[i])
        }
        print("Finishing training")
    }
    
    func predict(x:[Double]) -> Int {
        let mat = Matrix<Double>([x])
        var dist: [[Double]] = []
        for i in 0..<self.fNum {
            let d = getDistance(x: mat, y: features[i], sigma: sigma[labels[i]])
            dist.append([d, Double(labels[i])])
        }
        let sortedDist = dist.sorted { $0[0] < $1[0] }
        
        var kCount = [Int](repeating: 0, count: 21)
        kCount[Int(sortedDist[0][1])] += 1
        kCount[Int(sortedDist[1][1])] += 1
        kCount[Int(sortedDist[2][1])] += 1
        for i in 0..<21 {
            if kCount[i] > 2 {
                return i
            }
        }
        for i in 0..<21 {
            if kCount[i] > 0 {
                return i
            }
        }
        return 0
    }
    
    //Surge does not support matrix substract
    func matrixSub(x: Matrix<Double>, y: Matrix<Double>) -> Matrix<Double> {
        
        var xl = x[row: 0]
        var yl = y[row: 0]
        
        var res:[Double] = []
        
        for i in 0..<xl.count {
            res.append(xl[i] - yl[i])
        }
        return Matrix<Double>([res])
    }
    //Surge does not support matrix div by double
    func matrixDiv(x: Matrix<Double>, y:Double) -> Matrix<Double> {
        let l1 = x[row: 0]
        let l2 = x[row: 1]
        let l3 = x[row: 2]
        
        return Matrix<Double>([l1 / y, l2 / y, l3 / y])
    }
    
    //Get distance
    func getDistance(x: Matrix<Double>, y: Matrix<Double>, sigma: Matrix<Double>) -> Double {
        let sigmaInv = Surge.inv(sigma)
        let xyDiff = matrixSub(x: x, y: y)
        let tmp = Surge.mul(xyDiff, y:sigmaInv)
        let xyDiffT = Surge.transpose(xyDiff)
        let res = Surge.mul(tmp, y: xyDiffT)
        return res[row:0][0]
    }
    
    func saveStatus() {
        //convert features, mu, sigma to one dimensional array for saving
        var featuresNS: [Double] = []
        for f in features {
            featuresNS += f[row:0]
        }
        var muNS: [Double] = []
        for m in mu {
            muNS += m[row:0]
        }
        
        var sigmaNS: [Double] = []
        for sig in sigma {
            sigmaNS += sig[row:0]
            sigmaNS += sig[row:1]
            sigmaNS += sig[row:2]
        }
        let userDefault = UserDefaults.standard
        userDefault.set(featuresNS, forKey: "features")
        userDefault.set(labels, forKey: "labels")
        userDefault.set(muNS, forKey: "mu")
        userDefault.set(sigmaNS, forKey: "sigma")
        userDefault.set(fNum, forKey: "fnum")
        userDefault.synchronize()
        
        //Write to csv file
    }
    
    func restoreStatus() {
        let userDefault = UserDefaults.standard
        var featuresNS:[Double] = userDefault.array(forKey: "features") as! [Double]
        var muNS:[Double] = userDefault.array(forKey: "mu") as! [Double]
        let labelsNS:[Int] = userDefault.array(forKey: "labels") as! [Int]
        var sigmaNS: [Double] = userDefault.array(forKey: "sigma") as! [Double]
        let fNumNS = userDefault.integer(forKey: "fnum")
        
        
        //convert back
        var featuresBack:[Matrix<Double>] = []
        var muBack: [Matrix<Double>] = []
        var sigmaBack: [Matrix<Double>] = []
        var i = 0
        while i < fNumNS {
            featuresBack.append(Matrix<Double>([[featuresNS[i], featuresNS[i+1], featuresNS[i+2]]]))
            muBack.append(Matrix<Double>([[muNS[i], muNS[i+1], muNS[i+2]]]))
            i += 3
        }
        i = 0
        while i < fNumNS {
            let row1 = [sigmaNS[i], sigmaNS[i+1], sigmaNS[i+2]]
            let row2 =  [sigmaNS[i+3], sigmaNS[i+4], sigmaNS[i+5]]
            let row3 = [sigmaNS[i+6], sigmaNS[i+7], sigmaNS[i+8]]
            sigmaBack.append(Matrix<Double>([row1, row2, row3]))
            i += 9
        }
        self.features = featuresBack
        self.mu = muBack
        self.sigma = sigmaBack
        self.labels = labelsNS
        self.fNum = fNumNS
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }
    
    func writeToCSV(fileName: String, row: String) {
        let data = row.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        if FileManager.default.fileExists(atPath: fileName) {
            print("writing to " + fileName)
            if let fileHandle = FileHandle(forUpdatingAtPath: fileName) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
            else {
                print("Can't open fileHandle")
            }
        }
        else {
            FileManager.default.createFile(atPath: fileName, contents: nil, attributes: nil)
            print("File not exist")
            print("created" + fileName)
        }
    }
}
