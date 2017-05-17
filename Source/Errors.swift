//
//  Errors.swift
//  BoxCast
//
//  Created by Camden Fullmer on 5/13/17.
//  Copyright © 2017 BoxCast, Inc. All rights reserved.
//

import Foundation

/// Errors that occured accessing BoxCast API resources.
public enum BoxCastError: Error {
    /// The resource was unable to be serialized.
    case serializationError
}
