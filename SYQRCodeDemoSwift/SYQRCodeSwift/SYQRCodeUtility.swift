//
//  SYQRCodeUtility.swift
//  SYQRCodeDemoSwift
//
//  Created by ree.sun on 16-9-7.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

import Foundation
import UIKit
import AVFoundation

func SYLog<T>(message : T,methodName: String = __FUNCTION__, lineNumber: Int = __LINE__) {
    #if SY_DEBUG
        print("\(methodName).[\(lineNumber)]:\(message)")
    #endif
}

func SYLog<T>(message : T,methodName: String = __FUNCTION__, lineNumber: Int = __LINE__, classname: AnyObject!) {
    #if SY_DEBUG
        var classnameTemp = ""
        
        if classname != nil {
            classnameTemp = NSStringFromClass(classname.classForCoder) + "."
        }
        print("\(classnameTemp)\(methodName).[\(lineNumber)]:\(message)")
    #endif
}

func kIOS8_OR_LATER()-> Bool {
    if NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion:
        8, minorVersion: 0, patchVersion: 0)) {
            print("kIOS8_OR_LATER")
            return true
    }
    
    return false
}

func kIOS9_OR_LATER()-> Bool {
    if NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion:
        9, minorVersion: 0, patchVersion: 0)) {
            print("kIOS9_OR_LATER")
            return true
    }
    
    return false
}

func DEGREES_TO_RADIANS(degrees:Double)-> CGFloat {
    return CGFloat(degrees * M_PI / 180.0)
}

func alert(title:String!, msg:String!) {
    let vAlert = UIAlertView.init(title: title, message: msg, delegate: nil, cancelButtonTitle: "确定")
    vAlert.show()
}

func canAccessAVCaptureDeviceForMediaType(mediaType: String) -> Bool {
    var canAccess = false
    let status = AVCaptureDevice.authorizationStatusForMediaType(mediaType)
    
    if (status == .NotDetermined) {
        let dis_sema = dispatch_semaphore_create(0)
        AVCaptureDevice.requestAccessForMediaType(mediaType, completionHandler: { (granted:Bool) -> Void in
            dispatch_semaphore_signal(dis_sema);
            canAccess = granted
        })
        dispatch_semaphore_wait(dis_sema, DISPATCH_TIME_FOREVER);
    }
    else if (status == .Authorized) {
        canAccess = true
    }
    
    return canAccess
}

func getReaderViewBoundsWithSize(asize:CGSize) -> CGRect {
    return CGRectMake(kLineMinY / kSCREEN_HEIGHT, ((kSCREEN_WIDTH - asize.width) / 2.0) / kSCREEN_WIDTH, asize.height / kSCREEN_HEIGHT, asize.width / kSCREEN_WIDTH)
}

func generateQRCodeImage(strQRCode:String,strLogo:String!)->UIImage {
    let stringData = strQRCode.dataUsingEncoding(NSUTF8StringEncoding)
    
    //生成
    let qrFilter = CIFilter.init(name: "CIQRCodeGenerator")
    qrFilter?.setValue(stringData, forKey: "inputMessage")
    qrFilter?.setValue("M", forKey: "inputCorrectionLevel")

    let onColor = UIColor.whiteColor()
    let offColor = UIColor.darkGrayColor()
    
    //上色
    let colorFilter = CIFilter.init(name: "CIFalseColor")
    colorFilter!.setValue(qrFilter!.outputImage, forKey: "inputImage")
    colorFilter!.setValue(CIColor(color: onColor), forKey: "inputColor0")
    colorFilter!.setValue(CIColor(color: offColor), forKey: "inputColor1")
    
    //绘制
    let qrcodeImage = UIImage(CIImage: colorFilter!.outputImage!
        .imageByApplyingTransform(CGAffineTransformMakeScale(5, 5)))
    
    //中间logo
    if strLogo != nil {
        let logoImage = UIImage(named: strLogo)
        
        if logoImage != nil {
            let qrcodeRect = CGRectMake(0, 0, qrcodeImage.size.width, qrcodeImage.size.height)

            UIGraphicsBeginImageContext(qrcodeRect.size)
            qrcodeImage.drawInRect(qrcodeRect)
            
            let logoSize = CGSizeMake(qrcodeRect.size.width * 0.25, qrcodeRect.size.height * 0.25)
            let x = (qrcodeRect.width - logoSize.width) * 0.5
            let y = (qrcodeRect.height - logoSize.height) * 0.5
            
            //logo draw
            logoImage!.drawInRect(CGRectMake(x, y, logoSize.width, logoSize.height))
            
            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return resultImage
        }
    }
    return qrcodeImage
}

func readQRCodeImage(imagePicked:UIImage)->String! {
    let qrcodeImage : CIImage = CIImage(image: imagePicked)!
    let qrcodeContext = CIContext(options: nil)
    
    //检测图片中的二维码，并设置检测精度为高
    let qrcodeDetector : CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: qrcodeContext, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
    
    //读取图片的qrcode特性
    let qrcodeFeatures = qrcodeDetector.featuresInImage(qrcodeImage)
    
    //返回的结果，只读取第一条
    var qrcodeResultString : String! = nil
    for qrcodeFeature in qrcodeFeatures as! [CIQRCodeFeature] {
        if qrcodeResultString != nil {
            break
        }
        qrcodeResultString = qrcodeFeature.messageString;
        SYLog(qrcodeFeature.messageString)
    }
    
    return qrcodeResultString
}
