//
//  SYAVCaptureVideoPreviewLayer.swift
//  SYQRCodeDemoSwift
//
//  Created by ree.sun on 16-9-6.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

import AVFoundation

public class SYAVCaptureVideoPreviewLayer : NSObject {
    var videoPreviewLayer : AVCaptureVideoPreviewLayer?
    var session : AVCaptureSession?
    
    init! (frame: CGRect, rectOfInterest: CGRect, metadataObjectsDelegate: AVCaptureMetadataOutputObjectsDelegate) {
        super.init()

        var captureDevice : AVCaptureDevice?
        var input : AVCaptureDeviceInput?
        var output : AVCaptureMetadataOutput?

        for capDevice in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) {
            if ((capDevice as AnyObject).position == AVCaptureDevicePosition.back) {
                captureDevice = capDevice as? AVCaptureDevice
            }
        }
        
        if (captureDevice == nil) {
            return
        }
        
        if (!captureDevice!.hasTorch) {
            alertInfo("当前设备没有闪光灯",msg: nil)
        }
        
        let mSession = AVCaptureSession()
        
        //设置检测质量，质量越高扫描越精确，默认AVCaptureSessionPresetHigh
        if captureDevice!.supportsAVCaptureSessionPreset(AVCaptureSessionPreset1920x1080) {
            if mSession.canSetSessionPreset(AVCaptureSessionPreset1920x1080) {
                mSession.sessionPreset = AVCaptureSessionPreset1920x1080
            }
        }
        else if captureDevice!.supportsAVCaptureSessionPreset(AVCaptureSessionPreset1280x720) {
            if mSession.canSetSessionPreset(AVCaptureSessionPreset1280x720) {
                mSession.sessionPreset = AVCaptureSessionPreset1280x720
            }
        }
        
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        }
        catch let error as NSError {
            SYLog(error.debugDescription)
        }
        
        if (input == nil) {
            return
        }
        mSession.addInput(input)
        
        output = AVCaptureMetadataOutput.init()
        output!.setMetadataObjectsDelegate(metadataObjectsDelegate, queue: DispatchQueue.main)
        output!.rectOfInterest = rectOfInterest
        
        if mSession.canAddOutput(output) {
            mSession.addOutput(output)
        }
        else {
            return
        }
        
        var availableQRCodeType : Bool = false
        
        for availableType : Any in output!.availableMetadataObjectTypes {
            if (availableType is String) {
                if (availableType as AnyObject).lowercased.contains("qrcode") {
                    availableQRCodeType = true
                    SYLog(availableType)
                    
                    break
                }
            }
        }
        
        if availableQRCodeType {
            output!.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        }
        else {
            return
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: mSession)
        videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer!.frame = frame
        session = mSession;
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
