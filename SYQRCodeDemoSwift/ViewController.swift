//
//  ViewController.swift
//  SYQRCodeDemoSwift
//
//  Created by ree.sun on 16-9-6.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SYQRCodeReaderSwiftDelegate {
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

    @IBAction func onclickBtnScan(_ btn : UIButton!) {
        let vcQRCode = SYQRCodeReader()
        vcQRCode.setReaderDelegate(self)
        self.present(vcQRCode, animated: true, completion: nil)
    }
        
    @IBAction func onClickBtnGenerate(_ btn : UIButton!) {
        let imageQRCode = generateQRCodeImage("sunyang", strLogo: "qrcodelogo")
        self.logo.image = imageQRCode
    }
    
    @IBAction func onClickBtnRead(_ btn : UIButton!) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //代理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imagePicked = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //展示读取到的图片信息
        alertInfo(readQRCodeImage(imagePicked), msg: nil)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    //reader delegate
    func reader(reader: SYQRCodeReader!, didReadModel: SYQRCodeModel!, success: Bool) {
        self.mQRCode = didReadModel
        SYLog(self.mQRCode.describe(), classname: self)
        reader?.dismiss(animated: true, completion: { () -> Void in
            alertInfo(nil, msg: self.mQRCode.describe())
        })
    }
    
    func readerDidReadFail(reader: SYQRCodeReader!) {
        SYLog("readFailBlock", classname: self)
    }
}
