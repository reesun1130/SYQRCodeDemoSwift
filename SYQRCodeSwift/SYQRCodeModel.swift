//
//  SYQRCodeModel.swift
//  SYQRCodeDemoSwift
//
//  Created by ree.sun on 16-9-6.
//  Copyright © Ree Sun <ree.sun.cn@hotmail.com || 1507602555@qq.com>
//

import Foundation

public class SYQRCodeModel : NSObject {
    public var qrcodeValue : String?
    
    public init (qrcodeValue : String) {
        self.qrcodeValue = qrcodeValue
    }

    public func describe() -> String {
        return "SYQRCodeModel：qrcodeValue==" + self.qrcodeValue!
    }
}
