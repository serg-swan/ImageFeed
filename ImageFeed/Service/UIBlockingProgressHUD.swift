//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 03.06.2025.
//

import Foundation
import ProgressHUD
import UIKit

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
    
}
