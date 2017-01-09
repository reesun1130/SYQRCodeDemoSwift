//
//  SYQRCodeOverlayView.swift
//  SYQRCodeDemoSwift
//
//  Created by ree.sun on 16-9-6.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

import UIKit
import AVFoundation

class SYQRCodeOverlayView : UIView {
    var baseLayer : AVCaptureVideoPreviewLayer?
    
    init (frame: CGRect, baseLayer : AVCaptureVideoPreviewLayer!) {
        super.init(frame: frame)
        self.baseLayer = baseLayer
        self.createSubViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubViews() {
        //最上部view
        let upView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: kLineMinY))
        upView.alpha = 0.3
        upView.backgroundColor = UIColor.black
        self.addSubview(upView)
        
        //左侧的view
        let leftView = UIView.init(frame: CGRect(x: 0, y: upView.frame.maxY, width: (self.frame.size.width - kReaderViewWidth) / 2.0, height: kReaderViewHeight))
        leftView.alpha = 0.3
        leftView.backgroundColor = UIColor.black
        self.addSubview(leftView)
        
        //右侧的view
        let rightView = UIView.init(frame: CGRect(x: self.frame.size.width - leftView.frame.maxX, y: leftView.frame.minY, width: leftView.frame.width, height: leftView.frame.height))
        rightView.alpha = 0.3
        rightView.backgroundColor = UIColor.black
        self.addSubview(rightView)
        
        let space_h : CGFloat = self.frame.size.height - rightView.frame.maxY
        
        //底部view
        let downView = UIView.init(frame: CGRect(x: 0, y: rightView.frame.maxY, width: self.frame.width, height: space_h))
        downView.alpha = 0.3
        downView.backgroundColor = UIColor.black
        self.addSubview(downView)
        
        //线框
        let scanCropView = UIView.init(frame: CGRect(x: (self.frame.width - kReaderViewWidth) / 2.0, y: kLineMinY, width: kReaderViewWidth, height: kReaderViewHeight))
        scanCropView.layer.borderColor = UIColor.white.cgColor
        scanCropView.layer.borderWidth = 1.0
        self.baseLayer?.addSublayer(scanCropView.layer)
        
        //四个边角
        let cornerImage : UIImage = UIImage.init(named: "qrcode_corner")!
        
        //左侧的imageview
        let leftView_image : UIImageView = UIImageView.init(frame: CGRect(x: leftView.frame.maxX, y: upView.frame.maxY, width: cornerImage.size.width, height: cornerImage.size.height))
        leftView_image.image = cornerImage
        leftView_image.transform = CGAffineTransform(rotationAngle: DEGREES_TO_RADIANS(90))
        self.baseLayer?.addSublayer(leftView_image.layer)
        
        //右侧的imageview
        let rightView_image : UIImageView = UIImageView.init(frame: CGRect(x: rightView.frame.minX - leftView_image.frame.width + 1.0, y: leftView_image.frame.minY, width: leftView_image.frame.width, height: leftView_image.frame.height))
        rightView_image.image = cornerImage
        rightView_image.transform = CGAffineTransform(rotationAngle: DEGREES_TO_RADIANS(180))
        self.baseLayer?.addSublayer(rightView_image.layer)
        
        //左下角imageview
        let downView_image : UIImageView = UIImageView.init(frame: CGRect(x: leftView_image.frame.minX, y: downView.frame.minY - leftView_image.frame.height + 1.0, width: rightView_image.frame.width, height: rightView_image.frame.height))
        downView_image.image = cornerImage
        self.baseLayer?.addSublayer(downView_image.layer)
        
        //右下角imageview
        let downViewRight_image : UIImageView = UIImageView.init(frame: CGRect(x: rightView_image.frame.minX - 1.0, y: downView_image.frame.minY + 0.5, width: downView_image.frame.width, height: downView_image.frame.height))
        downViewRight_image.image = cornerImage
        downViewRight_image.transform = CGAffineTransform(rotationAngle: DEGREES_TO_RADIANS(270))
        self.baseLayer?.addSublayer(downViewRight_image.layer)


        let labIntroudction = UILabel.init(frame: CGRect(x: 0, y: downView.frame.minY + 15, width: self.frame.width, height: 20))
        labIntroudction.textAlignment = .center
        labIntroudction.font = UIFont.systemFont(ofSize: 14.0)
        labIntroudction.textColor = UIColor.white
        labIntroudction.text = "扫描PC端登录页面二维码即可实现自动登录"
        self.addSubview(labIntroudction)
    }
}
