//
//  UIImage+moa.swift
//  moa
//
//  Created by Alexander Kolov on 24.8.2017.
//  Copyright © 2017 Evgenii Neumerzhitckii. All rights reserved.
//

import UIKit

extension UIImage {

  private struct AssociatedKey {
    static var inflated = "moa_UIImage.Inflated"
  }

  /**
  
  Returns whether the image is inflated.
 
  */
  public var moa_inflated: Bool {
    get {
      if let inflated = objc_getAssociatedObject(self, &AssociatedKey.inflated) as? Bool {
        return inflated
      }
      else {
        return false
      }
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKey.inflated, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  /**
 
  Inflates the underlying compressed image data to be backed by an uncompressed bitmap representation.

  Inflating compressed image formats (such as PNG or JPEG) can significantly improve drawing performance as it
  allows a bitmap representation to be constructed in the background rather than on the main thread.
 
  */
  public func moa_inflate() {
    guard !moa_inflated else {
      return
    }

    dispatchPrecondition(condition: .notOnQueue(.main))
    moa_inflated = true
    _ = cgImage?.dataProvider?.data
  }

}
