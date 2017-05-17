//
//  UIKitExtensions.swift
//  BoxCast
//
//  Created by Camden Fullmer on 5/16/17.
//  Copyright © 2017 BoxCast, Inc. All rights reserved.
//

#if os(iOS)
import UIKit
#endif

class Device {

    static var modelIdentifierString: String {
        #if os(iOS)
            var systemInfo = utsname()
            uname(&systemInfo)
            let mirror = Mirror(reflecting: systemInfo.machine)
            
            let identifier = mirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            return identifier
        #else
            // TODO: Return model for macOS.
            return ""
        #endif
    }
    
}
