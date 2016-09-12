//
//  ViewController.swift
//  SYQRCodeDemoSwift
//
//  Created by ree.sun on 16-9-6.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var scan: UIButton!
    @IBOutlet weak var generate: UIButton!
    @IBOutlet weak var read: UIButton!
    @IBOutlet weak var logo: UIImageView!

    var mQRCode : SYQRCodeModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mQRCode = SYQRCodeModel(qrcodeValue: "sun")
        SYLog(mQRCode.describe(), classname: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onclickBtnScan(btn : UIButton!) {
        weak var weakSelf = self
        
        let vcQRCode = SYQRCodeReader.init()
        vcQRCode.readSuccessBlock { (vcQRCodeTemp, mQRCodeTemp) -> Void in
            weakSelf?.mQRCode = mQRCodeTemp
            SYLog(weakSelf?.mQRCode.describe(), classname: weakSelf)
            vcQRCodeTemp.dismissViewControllerAnimated(true, completion: { () -> Void in
                alert(nil, msg: weakSelf?.mQRCode.describe())
            })
        }
        vcQRCode.readFailBlock { (vcQRCodeTemp) -> Void in
            SYLog("readFailBlock", classname: weakSelf)
        }
        self.presentViewController(vcQRCode, animated: true, completion: nil)
    }
        
    @IBAction func onClickBtnGenerate(btn : UIButton!) {
        let imageQRCode = generateQRCodeImage("sunyang", strLogo: "qrcodelogo")
        self.logo.image = imageQRCode
    }
    
    @IBAction func onClickBtnRead(btn : UIButton!) {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    //代理
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let imagePicked = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //展示读取到的图片信息
        alert(readQRCodeImage(imagePicked), msg: nil)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
