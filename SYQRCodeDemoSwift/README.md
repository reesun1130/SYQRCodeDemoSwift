# SYQRCodeDemoSwift
SY QRCode Demo Swift，二维码扫描Swift实现，原生API，iOS8+

* oc实现: <a href="https://github.com/reesun1130/SYQRCodeDemo">SYQRCodeDemo</a>
* 效果：防微信二维码扫描
* 功能：扫描二维码、生成二维码


### Example：将SYQRCodeSwift拖入工程即可使用

``` objective-c
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
```

### 效果

![intro png](https://github.com/reesun1130/SYQRCodeDemoSwift/blob/master/qrcodes1.png)
![intro png](https://github.com/reesun1130/SYQRCodeDemoSwift/blob/master/qrcodes2.png)
