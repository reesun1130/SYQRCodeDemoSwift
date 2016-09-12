//
//  SYQRCodeModel.swift
//  SYQRCodeDemoSwift
//
//  Created by ree.sun on 16-9-6.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

import Foundation

class SYQRCodeModel : NSObject {
    var qrcodeValue : String?
    
    init (qrcodeValue : String) {
        self.qrcodeValue = qrcodeValue
    }

    func describe() -> String {
        return "SYQRCodeModel：qrcodeValue==" + self.qrcodeValue!
    }
}
