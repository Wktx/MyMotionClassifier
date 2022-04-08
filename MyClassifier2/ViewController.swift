//
//  ViewController.swift
//  MyClassifier2
//
//  Created by Kingston on 12/2/20.
//

import UIKit
import CoreML
import CoreMotion
import CoreData
class ViewController: UIViewController {
    var predictionlabel: UILabel!
    var seconds = 120
    var timer = Timer()
    var isTimerRunning = false
    var timerLabel: UILabel!
//    override func loadView() {
//        view = UIView()
//        view.backgroundColor = .white
//        let mainStackView = UIStackView()
//        view.addSubview(mainStackView)
//        let Prediction = UILabel()
//        Prediction.font = UIFont.preferredFont(forTextStyle: .headline)
//        Prediction.text = "Prediction"
//        Prediction.textAlignment = .center
//        mainStackView.addArrangedSubview(Prediction)
//    }
//
//    @objc func runTimer() {
//         timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
//    }
//    @objc func updateTimer() {
//        seconds -= 1     //This will decrement(count down)the seconds.
//        timerLabel.text = "\(seconds)" //This will update the label.
//    }
//
//
//
    
    let activityClassificationModel = MyActivityClassifier1()
    var currentIndexInPredictionWindow = 0
    var offset = 0
    let accelDataX = try! MLMultiArray(shape: [ModelConstants.predictionWindowSize] as [NSNumber], dataType: MLMultiArrayDataType.double)
    let accelDataY = try! MLMultiArray(shape: [ModelConstants.predictionWindowSize] as [NSNumber], dataType: MLMultiArrayDataType.double)
    let accelDataZ = try! MLMultiArray(shape: [ModelConstants.predictionWindowSize] as [NSNumber], dataType: MLMultiArrayDataType.double)

    let gyroDataX = try! MLMultiArray(shape: [ModelConstants.predictionWindowSize] as [NSNumber], dataType: MLMultiArrayDataType.double)
    let gyroDataY = try! MLMultiArray(shape: [ModelConstants.predictionWindowSize] as [NSNumber], dataType: MLMultiArrayDataType.double)
    let gyroDataZ = try! MLMultiArray(shape: [ModelConstants.predictionWindowSize] as [NSNumber], dataType: MLMultiArrayDataType.double)

    var stateOutput = try! MLMultiArray(shape:[ModelConstants.stateInLength as NSNumber], dataType: MLMultiArrayDataType.double)
    let motionManager = CMMotionManager()
//    print(motionManager.isAccelerometerAvailable)
//    print(motionManager.isGyroAvailable)
    
    
    
    
    
    override func viewDidLoad() {

        super.viewDidLoad()
//        view = UIView()
//        view.backgroundColor = .white
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center
        label.text = "Prediction:"
        self.view.addSubview(label)
        predict()
//        let label2 = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
//        label2.center = CGPoint(x: 160, y: 305)
//        label2.textAlignment = .center
//        label2.text = String("predictedActivity")
//        self.view.addSubview(label2)
//        runTimer()
        // Do any additional setup after loading the view.
    }
    
    
    
    
    
    struct ModelConstants {
        static let predictionWindowSize = 20
        static let sensorsUpdateInterval = 1.0 / 20.0
        //The LSTM incoming state
        static let stateInLength = 400
    }
    @objc func predict(){
//        let model = MyActivityClassifier()
//        let title: String
//        let label: String
//        do{
//            let prediction = try model.prediction(
//        }catch{
//        title
//        }
//
        print("hello")
        
//        let activityClassificationModel = MyActivityClassifier()
//        var currentIndexInPredictionWindow = 0
//
//        let accelDataX = try! MLMultiArray(shape: [ModelConstants.predictionWindowSize] as [NSNumber], dataType: MLMultiArrayDataType.double)
//        let accelDataY = try! MLMultiArray(shape: [ModelConstants.predictionWindowSize] as [NSNumber], dataType: MLMultiArrayDataType.double)
//        let accelDataZ = try! MLMultiArray(shape: [ModelConstants.predictionWindowSize] as [NSNumber], dataType: MLMultiArrayDataType.double)
//
//        let gyroDataX = try! MLMultiArray(shape: [ModelConstants.predictionWindowSize] as [NSNumber], dataType: MLMultiArrayDataType.double)
//        let gyroDataY = try! MLMultiArray(shape: [ModelConstants.predictionWindowSize] as [NSNumber], dataType: MLMultiArrayDataType.double)
//        let gyroDataZ = try! MLMultiArray(shape: [ModelConstants.predictionWindowSize] as [NSNumber], dataType: MLMultiArrayDataType.double)
//
//        var stateOutput = try! MLMultiArray(shape:[ModelConstants.stateInLength as NSNumber], dataType: MLMultiArrayDataType.double)
//        let motionManager = CMMotionManager()
//        print(motionManager.isAccelerometerAvailable)
//        print(motionManager.isGyroAvailable)
        
        //enable the motion manager
        guard motionManager.isAccelerometerAvailable, motionManager.isGyroAvailable else { return }

        motionManager.accelerometerUpdateInterval = TimeInterval(ModelConstants.sensorsUpdateInterval)
        motionManager.gyroUpdateInterval = TimeInterval(ModelConstants.sensorsUpdateInterval)

        motionManager.startAccelerometerUpdates(to: .main) { accelerometerData, error in
            guard let accelerometerData = accelerometerData else { return }
            self.addAccelSampleToDataArray(accelSample: accelerometerData)
            print("1")
//            self.addGyroSampleToDataArray(accelSample: accelerometerData)
        }
        motionManager.startGyroUpdates(to: .main) { gyroData, error in
            guard let gyroData = gyroData else { return }
            self.addGyroSampleToDataArray(gyroSample: gyroData)
            print("2")
            // Add the current data sample to the data array
            }
    }
        
    func addGyroSampleToDataArray (gyroSample: CMGyroData) {
        // Add the current accelerometer reading to the data array
        gyroDataX[[currentIndexInPredictionWindow] as [NSNumber]] = gyroSample.rotationRate.x as NSNumber
        gyroDataY[[currentIndexInPredictionWindow] as [NSNumber]] = gyroSample.rotationRate.y as NSNumber
        gyroDataZ[[currentIndexInPredictionWindow] as [NSNumber]] = gyroSample.rotationRate.z as NSNumber
        
    }
        

    func addAccelSampleToDataArray (accelSample: CMAccelerometerData) {
        // Add the current accelerometer reading to the data array
        accelDataX[[currentIndexInPredictionWindow] as [NSNumber]] = accelSample.acceleration.x as NSNumber
        accelDataY[[currentIndexInPredictionWindow] as [NSNumber]] = accelSample.acceleration.y as NSNumber
        accelDataZ[[currentIndexInPredictionWindow] as [NSNumber]] = accelSample.acceleration.z as NSNumber

        // Update the index in the prediction window data array
        currentIndexInPredictionWindow += 1
        print(currentIndexInPredictionWindow)
        // If the data array is full, call the prediction method to get a new model prediction.
        if (currentIndexInPredictionWindow == ModelConstants.predictionWindowSize) {
            if let predictedActivity = performModelPrediction() {
                offset += 1
                let label3 = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
                label3.center = CGPoint(x: 160, y: 285 + offset*15)
                label3.textAlignment = .center
                label3.text = String(predictedActivity)
                self.view.addSubview(label3)
                
                print(predictedActivity)
                // Start a new prediction window
                currentIndexInPredictionWindow = 0
            }
        }
    }
        
        func performModelPrediction () -> String? {
            // Perform model prediction
            let modelPrediction = try! activityClassificationModel.prediction(AccX: accelDataX, AccY: accelDataY, AccZ: accelDataZ, GyroX: gyroDataX, GyroY: gyroDataY, GyroZ: gyroDataZ, stateIn: stateOutput)

            // Update the state vector
            stateOutput = modelPrediction.stateOut

            // Return the predicted activity - the activity with the highest probability
            return modelPrediction.label
        }
        
    }



