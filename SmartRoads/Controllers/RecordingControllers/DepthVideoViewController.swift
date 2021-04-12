//
//  DepthVideoViewController.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 25.03.21.
//

import UIKit
import AVFoundation
import ARKit
import Photos
import CoreLocation
import RealmSwift
import CoreMotion

struct DataMove {
    var confidence: Int
    var Stationary: Bool
    var WALKING: Bool
    var cycling: Bool
    var running: Bool
    var unknown: Bool
    var automotive: Bool
}

class DepthVideoViewController: UIViewController {
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var confidenceView: UIImageView!
    @IBOutlet weak var arView: ARSCNView!
    
    lazy var textureCache = makeTextureCache()
    var arreyData = [DataMove]()

    var sliderValue: CGFloat = 0.0
    var previewMode = PreviewMode.original
    var filter = FilterType.comic
    let session = AVCaptureSession()
    let dataOutputQueue = DispatchQueue(label: "video data queue",
                                        qos: .userInitiated,
                                        attributes: [],
                                        autoreleaseFrequency: .workItem)
    let background: CIImage! = CIImage(image: UIImage(named: "earth-rise")!)
    var depthMap: CIImage?
    var mask: CIImage?
    var scale: CGFloat = 0.0
    var depthFilters = DepthImageFilters()
    var lastDepthMap: CVPixelBuffer?
    let sessionQueue = DispatchQueue(label: "ar camera recording queue")
    let runningqueue = OperationQueue()
    let runn = DispatchQueue(label: "motion manager queue")

    var arSession = ARSession()
    
    let backgroundRealm = LocalDataManager.realm
    let motion = CMMotionActivity()
    let motionactivityManager = CMMotionActivityManager()

    
    //MARK: for video
    var cameraIntrinsic: simd_float3x3?
    var colorFrameResolution: [Int] = []
    var depthFrameResolution: [Int] = []
    var frequency: Int?
    var username: String?
    var sceneDescription: String?
    var sceneType: String?
    var numFrames: Int = 0
    var dirUrl: URL!
    var recordingId: String = ""
    var isRecording: Bool = false
    var rgbRecorder: RGBRecorder! = nil // rgbRecorder will be initialized in configureSession
    var depthRecorder: DepthRecorder! = nil
    var confidenceRecorder: ConfidenceRecorder! = nil
    var sensorDataWrapper: SensorDataWrapper? = nil
    let locationManager = CLLocationManager()
    let motionManager = CMMotionManager()
    let localDataManager = LocalDataManager.shared
    var orientation = UIInterfaceOrientation.landscapeRight
    lazy var rotateToARCamera = makeRotateToARCameraMatrix(orientation: orientation)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //motionManagement()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupARSession()
        self.getGpsLocation(locationManager: locationManager)
        self.startAccelerometers()
        NotificationCenter.default.addObserver(self, selector: #selector(thermalStateChanged),
                                               name: ProcessInfo.thermalStateDidChangeNotification,    object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ProcessInfo.thermalStateDidChangeNotification, object: nil)
        arSession.pause()
        arView.session.pause()
    }
    
    func motionManagement() {
            motionactivityManager.startActivityUpdates(to: runningqueue) { (motionACtivity) in
                print("===============================")
                print("confidence: \(motionACtivity?.confidence.rawValue)???")
                print("Stationary: \(motionACtivity?.stationary)???")
                print("WALKING: \(motionACtivity?.walking)???")
                print("cycling: \(motionACtivity?.cycling)???")
                print("running: \(motionACtivity?.running)???")
                print("unknown: \(motionACtivity?.unknown)???")
                print("automotive: \(motionACtivity?.automotive)???")
                print("-----------------------")
//                let a = DataMove(confidence: motionACtivity!.confidence.rawValue, Stationary: motionACtivity!.stationary, WALKING: motionACtivity!.walking, cycling: motionACtivity!.cycling, running: motionACtivity!.running, unknown: motionACtivity!.unknown, automotive: motionACtivity!.automotive)
//                self.arreyData.append(a)
            }
    }
    
    func setupARSession() {
        //arSession.delegate = self
        arView.delegate = self
        arView.session.delegate = self
        let configuration = ARWorldTrackingConfiguration()
        configuration.frameSemantics = .sceneDepth
        //configuration.sceneReconstruction = .meshWithClassification
        //configuration.environmentTexturing = .automatic

       // arSession.run(configuration)
       // arView.session = arSession
        arView.session.run(configuration)
        if #available(iOS 14.0, *) {
            let videoFormat = configuration.videoFormat
            frequency = videoFormat.framesPerSecond
            let imageResolution = videoFormat.imageResolution
            colorFrameResolution = [Int(imageResolution.height), Int(imageResolution.width)]
            print(colorFrameResolution, frequency)
            
            let rgbVideoSettings: [String: Any] = [AVVideoCodecKey: AVVideoCodecType.jpeg, AVVideoHeightKey: NSNumber(value: colorFrameResolution[0]), AVVideoWidthKey: NSNumber(value: colorFrameResolution[1])]
            let depthVideoSetting: [String: Any] = [AVVideoCodecKey: AVVideoCodecType.jpeg, AVVideoHeightKey: 192, AVVideoWidthKey: 256]
            rgbRecorder = RGBRecorder(videoSettings: rgbVideoSettings)
            depthRecorder = DepthRecorder(videoSettings: depthVideoSetting)
           // confidenceRecorder = ConfidenceRecorder(videoSettings: videoSettings)
        } else {
            print("AR camera only available for iOS 14.0 or newer.")
            // TODO: do something
        }
    }
    
    @objc func thermalStateChanged(notification: NSNotification) {
        if let processInfo = notification.object as? ProcessInfo {
            showThermalState(state: processInfo.thermalState)
        }
    }
    
    func showThermalState(state: ProcessInfo.ThermalState) {
        DispatchQueue.main.async {
            var thermalStateString = "UNKNOWN"
            if state == .nominal {
                thermalStateString = "NOMINAL"
            } else if state == .fair {
                thermalStateString = "FAIR"
            } else if state == .serious {
                thermalStateString = "SERIOUS"
            } else if state == .critical {
                thermalStateString = "CRITICAL"
            }
            
            let message = NSLocalizedString("Thermal state: \(thermalStateString)", comment: "Alert message when thermal state has changed")
            let alertController = UIAlertController(title: "TrueDepthStreamer", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func startAccelerometers() {
       // Make sure the accelerometer hardware is available.
       if self.motionManager.isAccelerometerAvailable {
          self.motionManager.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
          self.motionManager.startAccelerometerUpdates()
       }
    }
    
    func getGpsLocation(locationManager: CLLocationManager) -> [Double] {

        var gpsLocation: [Double] = []
        
        if (locationManager.authorizationStatus == .authorizedWhenInUse ||
            locationManager.authorizationStatus == .authorizedAlways) {
            if let coordinate = locationManager.location?.coordinate {
                gpsLocation = [coordinate.latitude, coordinate.longitude]
            }
        } else if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        return gpsLocation
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
            orientation = .landscapeLeft
        } else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            orientation = .landscapeRight
        } else if UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown {
            orientation = .portraitUpsideDown
        } else {
            orientation = .portrait
        }
    }
    
    func cameraToDisplayRotation(orientation: UIInterfaceOrientation) -> Int {
        switch orientation {
        case .landscapeLeft:
            return 180
        case .portrait:
            return 90
        case .portraitUpsideDown:
            return -90
        default:
            return 0
        }
    }
    
    func makeRotateToARCameraMatrix(orientation: UIInterfaceOrientation) -> matrix_float4x4 {
        // flip to ARKit Camera's coordinate
        let flipYZ = matrix_float4x4(
            [1, 0, 0, 0],
            [0, -1, 0, 0],
            [0, 0, -1, 0],
            [0, 0, 0, 1] )

        let rotationAngle = Float(self.cameraToDisplayRotation(orientation: orientation)) * .degreesToRadian
        return flipYZ * matrix_float4x4(simd_quaternion(rotationAngle, Float3(0, 0, 1)))
    }
    
    
    @IBAction func didTapSaveVideo(_ sender: Any) {
        if self.isRecording {
            isRecording = false
            self.stopRecording()
//            DispatchQueue.main.async {
                self.localDataManager.saveDataWrapper(endDate: Date().dateInISO8601)
                self.button.backgroundColor = UIColor.green
                self.button.setTitle("Tap to start recording", for: .normal)
                
//            }
        } else {
//            DispatchQueue.main.async {
                self.localDataManager.createDataWrapper(startDate: Date().dateInISO8601)
                self.startRecording(username: "username", sceneDescription: "sceneDescription", sceneType: "sceneType")
                self.button.backgroundColor = UIColor.red
                self.button.setTitle("Tap to stop recording", for: .normal)
 //           }
        }
    }
}
