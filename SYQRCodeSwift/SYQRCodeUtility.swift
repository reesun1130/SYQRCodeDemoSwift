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

public func SYLog<T>(_ message : T,methodName: String = #function, lineNumber: Int = #line) {
    #if SY_DEBUG
        print("\(methodName).[\(lineNumber)]:\(message)")
    #endif
}

public func SYLog<T>(_ message : T,methodName: String = #function, lineNumber: Int = #line, classname: AnyObject!) {
    #if SY_DEBUG
        var classnameTemp = ""
        
        if classname != nil {
            classnameTemp = NSStringFromClass(classname.classForCoder) + "."
        }
        print("\(classnameTemp)\(methodName).[\(lineNumber)]:\(message)")
    #endif
}

public func kIOS8_OR_LATER()-> Bool {
    if ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion:
        8, minorVersion: 0, patchVersion: 0)) {
            print("kIOS8_OR_LATER")
            return true
    }
    
    return false
}

public func kIOS9_OR_LATER()-> Bool {
    if ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion:
        9, minorVersion: 0, patchVersion: 0)) {
            print("kIOS9_OR_LATER")
            return true
    }
    
    return false
}

public func DEGREES_TO_RADIANS(_ degrees:Double)-> CGFloat {
    return CGFloat(degrees * M_PI / 180.0)
}

public func alertInfo(_ title:String!, msg:String!) {
    let vAlert = UIAlertView.init(title: title, message: msg, delegate: nil, cancelButtonTitle: "确定")
    vAlert.show()
}

public func getReaderViewBoundsWithSize(_ asize:CGSize) -> CGRect {
    return CGRect(x: kLineMinY / kSCREEN_HEIGHT, y: ((kSCREEN_WIDTH - asize.width) / 2.0) / kSCREEN_WIDTH, width: asize.height / kSCREEN_HEIGHT, height: asize.width / kSCREEN_WIDTH)
}

public func generateQRCodeImage(_ strQRCode:String,strLogo:String!)->UIImage {
    let stringData = strQRCode.data(using: String.Encoding.utf8)
    
    //生成
    let qrFilter = CIFilter.init(name: "CIQRCodeGenerator")
    qrFilter?.setValue(stringData, forKey: "inputMessage")
    qrFilter?.setValue("M", forKey: "inputCorrectionLevel")

    let onColor = UIColor.white
    let offColor = UIColor.darkGray
    
    //上色
    let colorFilter = CIFilter.init(name: "CIFalseColor")
    colorFilter!.setValue(qrFilter!.outputImage, forKey: "inputImage")
    colorFilter!.setValue(CIColor(color: onColor), forKey: "inputColor0")
    colorFilter!.setValue(CIColor(color: offColor), forKey: "inputColor1")
    
    //绘制
    let qrcodeImage = UIImage(ciImage: colorFilter!.outputImage!
        .applying(CGAffineTransform(scaleX: 5, y: 5)))
    
    //中间logo
    if strLogo != nil {
        let logoImage = UIImage(named: strLogo)
        
        if logoImage != nil {
            let qrcodeRect = CGRect(x: 0, y: 0, width: qrcodeImage.size.width, height: qrcodeImage.size.height)

            UIGraphicsBeginImageContext(qrcodeRect.size)
            qrcodeImage.draw(in: qrcodeRect)
            
            let logoSize = CGSize(width: qrcodeRect.size.width * 0.25, height: qrcodeRect.size.height * 0.25)
            let x = (qrcodeRect.width - logoSize.width) * 0.5
            let y = (qrcodeRect.height - logoSize.height) * 0.5
            
            //logo draw
            logoImage!.draw(in: CGRect(x: x, y: y, width: logoSize.width, height: logoSize.height))
            
            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return resultImage!
        }
    }
    return qrcodeImage
}

public func readQRCodeImage(_ imagePicked:UIImage)->String! {
    let qrcodeImage : CIImage = CIImage(image: imagePicked)!
    let qrcodeContext = CIContext(options: nil)
    
    //检测图片中的二维码，并设置检测精度为高
    let qrcodeDetector : CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: qrcodeContext, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
    
    //读取图片的qrcode特性
    let qrcodeFeatures = qrcodeDetector.features(in: qrcodeImage)
    
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
