//
//  UIKitExtensions.swift
//  BoxCast
//
//  Created by Camden Fullmer on 5/16/17.
//  Copyright © 2017 BoxCast, Inc. All rights reserved.
//

import UIKit

extension UIDevice {
    /// Gets the identifier from the system, such as "iPhone7,1".
    var modelIdentifierString: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        
        let identifier = mirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
