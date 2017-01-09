//
//  SYQRCodeReader.swift
//  SYQRCodeDemoSwift
//
//  Created by ree.sun on 16-9-6.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

import UIKit
import AVFoundation

public class SYQRCodeReader : UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    fileprivate var vQRCode : SYQRCodeOverlayView!
    fileprivate var qrVideoPreviewLayer : SYAVCaptureVideoPreviewLayer!
    fileprivate var qrSession : AVCaptureSession!
    fileprivate var input : AVCaptureDeviceInput!
    fileprivate var output : AVCaptureMetadataOutput!
    fileprivate var captureDevice : AVCaptureDevice!
    fileprivate var _vActivityIndicator : UIActivityIndicatorView!
    fileprivate var _tipsLabel : UILabel!
    fileprivate var _line : UIImageView!
    fileprivate var _lineTimer : Timer!
    fileprivate var flag = true
    fileprivate var btnBack : UIButton!
    fileprivate var readerDelegate : SYQRCodeReaderSwiftDelegate!
    
    //读取之后的回调
//    fileprivate var suncessBlock : (SYQRCodeReader, SYQRCodeModel)->Void
//    fileprivate var failBlock : (SYQRCodeReader)->Void
//    
//    required public init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        //指示符
        self.createLoadingIndicator()
        
        //权限受限
        if (!canAccessAVCaptureDeviceForMediaType(AVMediaTypeVideo)) {
            self.showUnAuthorizedTips(true)
        }
        else {
            //延迟20ms加载，提高用户体验
            let delayTime = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * 0.02)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) { () -> Void in
                self.displayScanView()
            }
        }
    }
    
    func setReaderDelegate(_ readerDelegate: SYQRCodeReaderSwiftDelegate!) {
        self.readerDelegate = readerDelegate
    }
    
    func canAccessAVCaptureDeviceForMediaType(_ mediaType: String) -> Bool {
        var canAccess = false
        let status = AVCaptureDevice.authorizationStatus(forMediaType: mediaType)
        
        weak var weakSelf : SYQRCodeReader! = self
        
        if (status == .notDetermined) {
            let dis_sema = DispatchSemaphore(value: 0)
            AVCaptureDevice.requestAccess(forMediaType: mediaType, completionHandler: { (granted:Bool) -> Void in
                dis_sema.signal()
                canAccess = granted
                
                DispatchQueue.main.async {
                    weakSelf.showUnAuthorizedTips(!canAccess)
                }
            })
            _ = dis_sema.wait(timeout: DispatchTime.distantFuture)
        }
        else if (status == .authorized) {
            canAccess = true
        }
                
        return canAccess
    }

    //头
    fileprivate func createTopBar() {
        if btnBack == nil {
            btnBack = UIButton.init(frame: CGRect(x: 0, y: 0, width: 60, height: 64))
            btnBack.setTitle("关闭", for: UIControlState())
            btnBack.backgroundColor = UIColor.red
            btnBack.addTarget(self, action: #selector(SYQRCodeReader.onClickBtnBack), for: UIControlEvents.touchUpInside)
        }
        btnBack.removeFromSuperview()
        self.view.addSubview(btnBack)
    }
    
    func onClickBtnBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //提示符
    fileprivate func createLoadingIndicator() {
        _vActivityIndicator = UIActivityIndicatorView.init(frame: CGRect(x: (kSCREEN_WIDTH - 100) / 2.0, y: (kSCREEN_HEIGHT - 164)  / 2.0, width: 100, height: 100))
        _vActivityIndicator.hidesWhenStopped = true
        _vActivityIndicator.backgroundColor = UIColor.red
        _vActivityIndicator.startAnimating()
        self.view.addSubview(_vActivityIndicator)
    }
    
    //扫描视图
    fileprivate func displayScanView() {
        if self.loadCaptureUI() {
            self.showUnAuthorizedTips(false)

            weak var weakSelf : SYQRCodeReader!

            DispatchQueue.main.async(execute: { () -> Void in
                weakSelf.setOverlayPickerView()
                weakSelf.startSYQRCodeReading()
            })
        }
        else {
            self.showUnAuthorizedTips(true)
        }
    }

    fileprivate func loadCaptureUI() -> Bool {
        qrVideoPreviewLayer = SYAVCaptureVideoPreviewLayer(frame: CGRect(x: 0, y: 0, width: kSCREEN_WIDTH, height: kSCREEN_HEIGHT), rectOfInterest: getReaderViewBoundsWithSize(CGSize(width: 200, height: 200)), metadataObjectsDelegate: self)
        
        if (qrVideoPreviewLayer.videoPreviewLayer == nil) {
            return false
        }
        qrSession = qrVideoPreviewLayer.session
        
        return true
    }
    
    fileprivate func setOverlayPickerView() {
        vQRCode = SYQRCodeOverlayView(frame: CGRect(x: 0,y: 0,width: kSCREEN_WIDTH,height: kSCREEN_HEIGHT), baseLayer: qrVideoPreviewLayer.videoPreviewLayer)
        self.view.addSubview(vQRCode)
        self.view.layer.insertSublayer(qrVideoPreviewLayer.videoPreviewLayer!, at: 0)
        
        //添加过渡动画，类似微信
        let animationLayer = CAKeyframeAnimation.init(keyPath: "transform")
        animationLayer.duration = 0.1
        
        let values = NSMutableArray.init(capacity: 2)
        values.add(NSValue(caTransform3D: CATransform3DMakeScale(0.1, 0.1, 1.0)))
        values.add(NSValue(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0)))
        animationLayer.values = values as [AnyObject]
        qrVideoPreviewLayer.videoPreviewLayer!.add(animationLayer, forKey: nil)
        
        //添加导航栏
        self.createTopBar()
    }

    //权限受限
    fileprivate func showUnAuthorizedTips(_ flag:Bool) {
        if (_tipsLabel == nil) {
            _tipsLabel = UILabel.init(frame: CGRect(x: 8, y: 0, width: self.view.frame.size.width - 16, height: 300))
            _tipsLabel.textAlignment = .center
            _tipsLabel.textColor = UIColor.black
            _tipsLabel.numberOfLines = 0
            _tipsLabel.isUserInteractionEnabled = true
            _tipsLabel.text = "请在'设置-隐私-相机\'选项中，\r允许APP访问你的相机。"
            self.view.addSubview(_tipsLabel)

            let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(SYQRCodeReader._handleTipsTap))
            _tipsLabel.addGestureRecognizer(tapGes)
        }
        
        if flag {
            _vActivityIndicator.stopAnimating()
            
            //添加导航栏
            self.createTopBar()
        }
        
        _tipsLabel.isHidden = !flag
    }
    
    func _handleTipsTap() {
        UIApplication.shared.openURL(URL.init(string: "prefs:root")!)
    }

    //开始扫描
    fileprivate func startSYQRCodeReading() {
        qrSession.startRunning()
        _vActivityIndicator.stopAnimating()

        if _line == nil {
            _line = UIImageView.init(frame: CGRect(x: (kSCREEN_WIDTH - 216) / 2.0, y: kLineMinY, width: 216, height: 1))
            _line.image = UIImage.init(named: "qrcode_blueline")
            qrVideoPreviewLayer.videoPreviewLayer!.addSublayer(_line.layer)
        }
        
        _lineTimer = Timer.scheduledTimer(timeInterval: 1.0 / 20, target: self, selector: #selector(SYQRCodeReader.animationLine), userInfo: nil, repeats: true)
        qrSession.startRunning()
    }
    
    //结束扫描
    fileprivate func stopSYQRCodeReading() {
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
    fileprivate func cancleSYQRCodeReading() {
        self.stopSYQRCodeReading()
        SYLog("cancle reading", classname: self)
    }
    
    //扫描代理
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
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
            
            if (strResponse != nil && strResponse != "" && !(strResponse?.characters.isEmpty)!) {
                SYLog("qrcodestring=="+strResponse!, classname: self)
                
                if (strResponse?.hasPrefix("http"))! {
                    fail = false
                    AudioServicesPlaySystemSound(1360)
                    if self.readerDelegate != nil {
                        let mqrcode = SYQRCodeModel.init(qrcodeValue: strResponse!)
                        self.readerDelegate.reader(reader: self, didReadModel: mqrcode, success: true)
                    }
                }
            }
        }
        
        if (fail) {
            SYLog("reading fail", classname: self)
            
            if self.readerDelegate != nil {
                self.readerDelegate.readerDidReadFail(reader: self)
            }
        }
    }
    
    //扫毛动画
    func animationLine() {
        var frame = _line.frame
        
        if (flag) {
            frame.origin.y = kLineMinY
            flag = false
            UIView.animate(withDuration: 1.0 / 20, animations: { () -> Void in
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
                    UIView.animate(withDuration: 1.0 / 20, animations: { () -> Void in
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

protocol SYQRCodeReaderSwiftDelegate : NSObjectProtocol {
    @available(iOS 8.0, *)
    func reader(reader : SYQRCodeReader!, didReadModel : SYQRCodeModel!, success : Bool)
    func readerDidReadFail(reader : SYQRCodeReader!)
}
