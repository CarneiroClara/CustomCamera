//
//  CameraViewController.swift
//  CustomCamera
//
//  Created by Clara Carneiro on 7/27/17.
//  Copyright © 2017 Clara Carneiro. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate{
    
    // status bar with white text color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet var flashButton: UIButton!
    @IBOutlet var positionButton: UIButton!
    var frontPosition = false
    var flashEnable = false
    let flashOnIcon = #imageLiteral(resourceName: "FlashSelected") as UIImage
    let flashOffIcon = #imageLiteral(resourceName: "Flash") as UIImage
    let frontCameraIcon = #imageLiteral(resourceName: "CameraFrontal") as UIImage
    let backCameraIcon = #imageLiteral(resourceName: "CameraTraseira") as UIImage
    
    // manages capture activity and coordinates the flow of data
    // from input devices to capture outputs.
    var captureSession = AVCaptureSession()
    
    // represent the actual iPhone device camera
    var backCamera : AVCaptureDevice?
    var frontCamera : AVCaptureDevice?
    var currentCamera : AVCaptureDevice?
    
    // a capture output for use in workflows related to still photography
    var photoOutput:  AVCapturePhotoOutput?
    
    // holds the data of the captured photo
    var photoData: Data?
    
    // a Core Animation layer that can display video as it is being captured.
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupDevice()
        //setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()

    }
    
    func setupCaptureSession() {
        
        /* 
        
         .sessionPresent: customize the quality level or bitrate of the output
         
         VALUES:
         
            Quality levels:
         
                AVCaptureSessionPresetPhoto for high resolution photo quality output
         
                AVCaptureSessionPresetMedium for output video and audio bitrates suitable
                for sharing over WiFi.
         
                AVCaptureSessionPresetLow for output video and audio bitrates suitable
                for sharing over 3G.
         
         
            Bitrates:
         
                AVCaptureSessionPreset640x480 for VGA quality video output.
         
                AVCaptureSessionPreset960x540 for quarter HD quality video output.
         
                AVCaptureSessionPreset1280x720 for 720p quality video output.
         
                AVCaptureSessionPreset1920x1080 for 1080p quality video output.
         
                AVCaptureSessionPreset3840x2160 for 2160p (also called UHD or 4K) 
                quality video output.
        */
        
        // set the quality level of the output as a high resolution photo
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
    }
    
    func setupDevice() {
        
        
        /*
         AVCaptureDeviceDiscoverySession: finding and monitoring available capture devices
         
         Use this class to find all available capture devices matching a specific device type
         (such as microphone or wide-angle camera), supported media types for capture (such as
         audio, video, or both), and position (front- or back-facing).
         
         After creating a device discovery session, you can inspect its devices array to choose
         a device for capture, or observe that property to be notified when devices become
         available or unavailable.
         */
        
        // finding devices that match with builtInWideAngleCamera device type
        let deviceDiscoverySession = AVCaptureDeviceDiscoverySession(__deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: AVCaptureDevicePosition.unspecified)

        if let devices = deviceDiscoverySession.devices {
        
            for device in devices {
                //  check physical position of the device hardware on the system
                if device.position == AVCaptureDevicePosition.back{
                    backCamera = device
                }
                else if device.position == AVCaptureDevicePosition.front {
                    frontCamera = device
                }
                
                if frontPosition{
                    positionButton.setBackgroundImage(backCameraIcon, for: UIControlState.normal)
                    currentCamera = frontCamera
                }
                else {
                    positionButton.setBackgroundImage(frontCameraIcon, for: UIControlState.normal)
                    currentCamera = backCamera
                }
                
            }
            setupInputOutput()
        }
        
        else { print ("can't find devices with builtInWideAngleCamera device type") }
        
    }
    
    func setupInputOutput() {
        
        /*
         AVCaptureDeviceInput is a concrete sub-class of AVCaptureInput you use to capture data from an AVCaptureDevice object.
         
         It throws an error in cases of failure. You call this method in a try expression and handle any errors in the catch
         clauses of a do statement
         
         PARAMETERS:
            The device from which to capture input.
                device: AVCaptureDevice!
         
            If an error occurs during initialization, upon return contains an NSError object describing the problem.
                _ outError: NSError
         */
        
        do {
            // set up Input 
            
            // a capture input that provides media from a capture device to a capture session.
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            // provide media input to the capture session
            captureSession.addInput(captureDeviceInput)
            
            // set up Output
            
            photoOutput = AVCapturePhotoOutput()
            // tells the photo capture output to prepare resources for future capture requests with JPEG format
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecJPEG])], completionHandler: nil)
            // adds a given output to the session
            captureSession.addOutput(photoOutput!)
        }
        catch {print(error)}
    }
    
    func setupPreviewLayer() {
        // initializes the preview layer with the capture session.
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        if cameraPreviewLayer != nil {
            /*  .videoGravity 
                    Indicates how the video is displayed within a player layer’s bounds rect
                .connection 
                    The capture connection describing the AVCaptureInputPort to which the preview layer is connected.
             
             */
            
            // makes a full screen preview layer at a portrait orientation
            cameraPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            cameraPreviewLayer?.frame = self.view.frame
            self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        }
        
        else {
            print ("can't initiate AVCaptureVideoPreviewLayer")
        }
    }
    
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    // capture an image
    @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        if flashEnable {settings.flashMode = .on}
        else {settings.flashMode = .off}
        photoOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
    }
    
    // implement the AVCapturePhotoCaptureDelegate protocol
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let photoSampleBuffer = photoSampleBuffer {
            photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            image = UIImage(data: photoData!)
            performSegue(withIdentifier: "showPhoto_segue", sender: nil)

        }
        else {
            print(error!)
            return
        }
    }
    
    // override prepare for segue to pass a content to destination view before perform
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhoto_segue"{
            let previewViewController = segue.destination as! PreviewViewController
            previewViewController.image = self.image
        }
        
    }
    
    @IBAction func positionButton_TouchUpInside(_ sender: Any) {
        self.frontPosition = !self.frontPosition
        captureSession.beginConfiguration()
        let inputs = captureSession.inputs as! [AVCaptureInput]
        for oldInput: AVCaptureInput in inputs {captureSession.removeInput(oldInput)}
        let outputs = captureSession.outputs as! [AVCaptureOutput]
        for oldOutput: AVCaptureOutput in outputs {captureSession.removeOutput(oldOutput)}
        setupDevice()
        captureSession.commitConfiguration()
    }
    
    
    @IBAction func flashButton_TouchUpInside(_ sender: Any) {
        if self.flashEnable{
            self.flashEnable = false
            self.flashButton.setBackgroundImage(flashOffIcon, for: UIControlState.normal)
        }
        else{
            self.flashEnable = true
            self.flashButton.setBackgroundImage(flashOnIcon, for: UIControlState.normal)
        }
    }

}

