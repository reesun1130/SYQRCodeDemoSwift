//
//  SYQRCodeReader.swift
//  SYQRCodeDemoSwift
//
//  Created by ree.sun on 16-9-6.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

import UIKit
import AVFoundation

class SYQRCodeReader : UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private var vQRCode : SYQRCodeOverlayView!
    private var qrVideoPreviewLayer : SYAVCaptureVideoPreviewLayer!
    private var qrSession : AVCaptureSession!
    private var input : AVCaptureDeviceInput!
    private var output : AVCaptureMetadataOutput!
    private var captureDevice : AVCaptureDevice!
    private var _vActivityIndicator : UIActivityIndicatorView!
    private var _tipsLabel : UILabel!
    private var _line : UIImageView!
    private var _lineTimer : NSTimer!
    private var flag = true
    private var btnBack : UIButton!
    
    //读取之后的回调
    typealias SYQRCodeSuncessBlock = (SYQRCodeReader, SYQRCodeModel)->Void
    typealias SYQRCodeFailBlock = (SYQRCodeReader)->Void
    
    private var suncessBlock = SYQRCodeSuncessBlock?()
    private var failBlock = SYQRCodeFailBlock?()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()

        //指示符
        self.createLoadingIndicator()
        
        //权限受限
        if (!canAccessAVCaptureDeviceForMediaType(AVMediaTypeVideo)) {
            self.showUnAuthorizedTips(true)
        }
        else {
            //延迟20ms加载，提高用户体验
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * 0.02))
            dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
                self.displayScanView()
            }
        }
    }
    
    //回调
    func readSuccessBlock(ablock:(SYQRCodeReader!, SYQRCodeModel!)->Void) {
        suncessBlock = ablock
    }
    
    func readFailBlock(ablock:(SYQRCodeReader!)->Void) {
        failBlock = ablock
    }

    //头
    private func createTopBar() {
        if btnBack == nil {
            btnBack = UIButton.init(frame: CGRectMake(0, 0, 60, 64))
            btnBack.setTitle("关闭", forState: UIControlState.Normal)
            btnBack.backgroundColor = UIColor.redColor()
            btnBack.addTarget(self, action: Selector("onClickBtnBack"), forControlEvents: UIControlEvents.TouchUpInside)
        }
        btnBack.removeFromSuperview()
        self.view.addSubview(btnBack)
    }
    
    func onClickBtnBack() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //提示符
    private func createLoadingIndicator() {
        _vActivityIndicator = UIActivityIndicatorView.init(frame: CGRectMake((kSCREEN_WIDTH - 100) / 2.0, (kSCREEN_HEIGHT - 164)  / 2.0, 100, 100))
        _vActivityIndicator.hidesWhenStopped = true
        _vActivityIndicator.backgroundColor = UIColor.redColor()
        _vActivityIndicator.startAnimating()
        self.view.addSubview(_vActivityIndicator)
    }
    
    //扫描视图
    private func displayScanView() {
        if self.loadCaptureUI() {
            self.showUnAuthorizedTips(false)

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.setOverlayPickerView()
                self.startSYQRCodeReading()
            })
        }
        else {
            self.showUnAuthorizedTips(true)
        }
    }

    private func loadCaptureUI() -> Bool {
        qrVideoPreviewLayer = SYAVCaptureVideoPreviewLayer(frame: CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT), rectOfInterest: getReaderViewBoundsWithSize(CGSizeMake(200, 200)), metadataObjectsDelegate: self)
        
        if (qrVideoPreviewLayer.videoPreviewLayer == nil) {
            return false
        }
        qrSession = qrVideoPreviewLayer.session
        
        return true
    }
    
    private func setOverlayPickerView() {
        vQRCode = SYQRCodeOverlayView(frame: CGRect(x: 0,y: 0,width: kSCREEN_WIDTH,height: kSCREEN_HEIGHT), baseLayer: qrVideoPreviewLayer.videoPreviewLayer)
        self.view.addSubview(vQRCode)
        self.view.layer.insertSublayer(qrVideoPreviewLayer.videoPreviewLayer!, atIndex: 0)
        
        //添加过渡动画，类似微信
        let animationLayer = CAKeyframeAnimation.init(keyPath: "transform")
        animationLayer.duration = 0.1;
        
        let values = NSMutableArray.init(capacity: 2)
        values.addObject(NSValue(CATransform3D: CATransform3DMakeScale(0.1, 0.1, 1.0)))
        values.addObject(NSValue(CATransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0)))
        animationLayer.values = values as [AnyObject]
        qrVideoPreviewLayer.videoPreviewLayer!.addAnimation(animationLayer, forKey: nil)
        
        //添加导航栏
        self.createTopBar()
    }

    //权限受限
    private func showUnAuthorizedTips(flag:Bool) {
        if (_tipsLabel == nil) {
            _tipsLabel = UILabel.init(frame: CGRectMake(8, 0, self.view.frame.size.width - 16, 300))
            _tipsLabel.textAlignment = .Center
            _tipsLabel.textColor = UIColor.blackColor()
            _tipsLabel.numberOfLines = 0
            _tipsLabel.userInteractionEnabled = true
            _tipsLabel.text = "请在'设置-隐私-相机\'选项中，\r允许APP访问你的相机。"
            self.view.addSubview(_tipsLabel)

            let tapGes = UITapGestureRecognizer.init(target: self, action: Selector("_handleTipsTap"))
            _tipsLabel.addGestureRecognizer(tapGes)
        }
        
        if flag {
            _vActivityIndicator.stopAnimating()
            
            //添加导航栏
            self.createTopBar()
        }
        
        _tipsLabel.hidden = !flag
    }
    
    func _handleTipsTap() {
        UIApplication.sharedApplication().openURL(NSURL.init(string: "prefs:root")!)
    }

    //开始扫描
    private func startSYQRCodeReading() {
        qrSession.startRunning()
        _vActivityIndicator.stopAnimating()

        if _line == nil {
            _line = UIImageView.init(frame: CGRectMake((kSCREEN_WIDTH - 216) / 2.0, kLineMinY, 216, 1))
            _line.image = UIImage.init(named: "qrcode_blueline")
            qrVideoPreviewLayer.videoPreviewLayer!.addSublayer(_line.layer)
        }
        
        _lineTimer = NSTimer.scheduledTimerWithTimeInterval(1.0 / 20, target: self, selector: Selector("animationLine"), userInfo: nil, repeats: true)
        qrSession.startRunning()
    }
    
    //结束扫描
    private func stopSYQRCodeReading() {
        if (_lineTimer != nil) {
            _lineTimer.invalidate()
            _lineTimer = nil
        }
        
        if (qrSession != nil) {
            qrSession.stopRunning()
            qrSession = nil
        }
        
        SYLog("stop reading", classname: self)
    }
    
    //取消扫描
    private func cancleSYQRCodeReading() {
        self.stopSYQRCodeReading()
        SYLog("cancle reading", classname: self)
    }
    
    //扫描代理
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        self.stopSYQRCodeReading()
        var fail = true
        
        //扫描结果
        if (metadataObjects.count > 0) {
            let responseObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            //        //org.iso.QRCode
            //        if ([responseObj.type containsString:@"QRCode"]) {
            //
            //        }
            let strResponse = responseObj.stringValue
            
            if (strResponse != nil && strResponse != "" && !strResponse.characters.isEmpty) {
                SYLog("qrcodestring=="+strResponse, classname: self)
                
                if (strResponse.hasPrefix("http")) {
                    fail = false
                    AudioServicesPlaySystemSound(1360)
                    if self.suncessBlock != nil {
                        let mqrcode = SYQRCodeModel.init(qrcodeValue: strResponse)
                        self.suncessBlock!(self, mqrcode)
                    }
                }
            }
        }
        
        if (fail) {
            SYLog("reading fail", classname: self)
            if self.failBlock != nil {
                self.failBlock!(self)
            }
        }
    }
    
    //扫毛动画
    func animationLine() {
        var frame = _line.frame
        
        if (flag) {
            frame.origin.y = kLineMinY
            flag = false
            UIView.animateWithDuration(1.0 / 20, animations: { () -> Void in
                frame.origin.y += 5
                self._line.frame = frame
            })
        }
        else {
            if (_line.frame.origin.y >= kLineMinY) {
                if (_line.frame.origin.y >= kLineMaxY - 12) {
                    frame.origin.y = kLineMinY
                    _line.frame = frame
                    flag = true
                }
                else {
                    UIView.animateWithDuration(1.0 / 20, animations: { () -> Void in
                        frame.origin.y += 5
                        self._line.frame = frame
                    })
                }
            }
            else {
                flag = !flag
            }
        }
    }
}
