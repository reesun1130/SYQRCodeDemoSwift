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
        let upView = UIView.init(frame: CGRectMake(0, 0, self.frame.size.width, kLineMinY))
        upView.alpha = 0.3
        upView.backgroundColor = UIColor.blackColor()
        self.addSubview(upView)
        
        //左侧的view
        let leftView = UIView.init(frame: CGRectMake(0, CGRectGetMaxY(upView.frame), (self.frame.size.width - kReaderViewWidth) / 2.0, kReaderViewHeight))
        leftView.alpha = 0.3
        leftView.backgroundColor = UIColor.blackColor()
        self.addSubview(leftView)
        
        //右侧的view
        let rightView = UIView.init(frame: CGRectMake(self.frame.size.width - CGRectGetMaxX(leftView.frame), CGRectGetMinY(leftView.frame), CGRectGetWidth(leftView.frame), CGRectGetHeight(leftView.frame)))
        rightView.alpha = 0.3
        rightView.backgroundColor = UIColor.blackColor()
        self.addSubview(rightView)
        
        let space_h : CGFloat = self.frame.size.height - CGRectGetMaxY(rightView.frame)
        
        //底部view
        let downView = UIView.init(frame: CGRectMake(0, CGRectGetMaxY(rightView.frame), CGRectGetWidth(self.frame), space_h))
        downView.alpha = 0.3
        downView.backgroundColor = UIColor.blackColor()
        self.addSubview(downView)
        
        //线框
        let scanCropView = UIView.init(frame: CGRectMake((CGRectGetWidth(self.frame) - kReaderViewWidth) / 2.0, kLineMinY, kReaderViewWidth, kReaderViewHeight))
        scanCropView.layer.borderColor = UIColor.whiteColor().CGColor
        scanCropView.layer.borderWidth = 1.0
        self.baseLayer?.addSublayer(scanCropView.layer)
        
        //四个边角
        let cornerImage : UIImage = UIImage.init(named: "qrcode_corner")!
        
        //左侧的imageview
        let leftView_image : UIImageView = UIImageView.init(frame: CGRectMake(CGRectGetMaxX(leftView.frame), CGRectGetMaxY(upView.frame), cornerImage.size.width, cornerImage.size.height))
        leftView_image.image = cornerImage
        leftView_image.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90))
        self.baseLayer?.addSublayer(leftView_image.layer)
        
        //右侧的imageview
        let rightView_image : UIImageView = UIImageView.init(frame: CGRectMake(CGRectGetMinX(rightView.frame) - CGRectGetWidth(leftView_image.frame) + 1.0, CGRectGetMinY(leftView_image.frame), CGRectGetWidth(leftView_image.frame), CGRectGetHeight(leftView_image.frame)))
        rightView_image.image = cornerImage
        rightView_image.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180))
        self.baseLayer?.addSublayer(rightView_image.layer)
        
        //左下角imageview
        let downView_image : UIImageView = UIImageView.init(frame: CGRectMake(CGRectGetMinX(leftView_image.frame), CGRectGetMinY(downView.frame) - CGRectGetHeight(leftView_image.frame) + 1.0, CGRectGetWidth(rightView_image.frame), CGRectGetHeight(rightView_image.frame)))
        downView_image.image = cornerImage
        self.baseLayer?.addSublayer(downView_image.layer)
        
        //右下角imageview
        let downViewRight_image : UIImageView = UIImageView.init(frame: CGRectMake(CGRectGetMinX(rightView_image.frame) - 1.0, CGRectGetMinY(downView_image.frame) + 0.5, CGRectGetWidth(downView_image.frame), CGRectGetHeight(downView_image.frame)))
        downViewRight_image.image = cornerImage
        downViewRight_image.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(270))
        self.baseLayer?.addSublayer(downViewRight_image.layer)


        let labIntroudction = UILabel.init(frame: CGRectMake(0, CGRectGetMinY(downView.frame) + 15, CGRectGetWidth(self.frame), 20))
        labIntroudction.textAlignment = .Center
        labIntroudction.font = UIFont.systemFontOfSize(14.0)
        labIntroudction.textColor = UIColor.whiteColor()
        labIntroudction.text = "扫描PC端登录页面二维码即可实现自动登录"
        self.addSubview(labIntroudction)
    }
}
