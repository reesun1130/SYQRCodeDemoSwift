# SYQRCodeDemoSwift

## Introduce
### SY QRCode Demo Swift，二维码扫描Swift实现，原生API，iOS8+ 
### Version 1.0.5

* Objective-C实现:
  * <a href="https://github.com/reesun1130/SYQRCodeDemo">SYQRCodeDemo</a>
* 效果：
  * 仿微信二维码扫描
* 功能：
  * 扫描二维码
  * 生成二维码
  * 读取相册中二维码图片


## Example

``` objective-c
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
```

## UI

![intro png](https://github.com/reesun1130/SYQRCodeDemoSwift/blob/master/SYQRCodeDemoSwift/qrcodes1.png)

![intro png](https://github.com/reesun1130/SYQRCodeDemoSwift/blob/master/SYQRCodeDemoSwift/qrcodes2.png)

## Installation

### CocoaPods

* [CocoaPods](http://cocoapods.org) is a dependency manager for Swift and Objective-C Cocoa projects, which automates and simplifies the process of using 3rd-party libraries like SYQRCodeSwift in your projects. 
* [CocoaPods](http://cocoapods.org) can help you scale your projects elegantly.
* See the [Getting Started](https://guides.cocoapods.org/using/getting-started.html) guide for more information.

```ruby
# Your Podfile
platform :ios, '8.0'
pod 'SYQRCodeSwift'
```

### Manually

1.	直接拷贝 `SYQRCodeSwift/`目录到你的project
2.	添加frameworks：`Foundation`、`UIKit`、`AVFoundation`

## Usage

### Swift

1. 初始化：
 * `let vcQRCode = SYQRCodeReader()`
2. 设置代理：
 * `vcQRCode.setReaderDelegate(self)`
3. 打开扫描界面：
 * `self.present(vcQRCode, animated: true, completion: nil)`
4. 实现代理（SYQRCodeReaderSwiftDelegate）：
 * `reader(reader : SYQRCodeReader!, didReadModel : SYQRCodeModel!, success : Bool)`
 * `readerDidReadFail(reader : SYQRCodeReader!)`


## Enviroment

- iOS 8+
- Swift
- Support armv7/armv7s/arm64

## Misc

### Author

- Name: [Ree Sun](https://github.com/reesun1130)
- Email: <ree.sun.cn@hotmail.com>

### License

This code is distributed under the terms and conditions of the MIT license. 

### Contribution guidelines

**NB!** If you are fixing a bug you discovered, please add also a unit test so I know how exactly to reproduce the bug before merging.
