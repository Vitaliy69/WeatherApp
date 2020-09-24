//
//  Extensions.swift
//  WeatherApp
//
//  Created by Vitaliy on 23.09.2020.
//  Copyright © 2020 Vitaliy Gribko. All rights reserved.
//

import Foundation
import UIKit

extension DispatchGroup {
    
    func notifyWait(target: DispatchQueue, timeout: DispatchTime, handler: @escaping (() -> Void)) {
        DispatchQueue.global(qos: .default).async {
            _ = self.wait(timeout: timeout)
            target.async {
                handler()
            }
        }
    }
}

extension UILabel {
    
    func addLeading(image: UIImage, size: CGSize) {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let attachmentString = NSAttributedString(attachment: attachment)
        let string = NSMutableAttributedString()
        
        string.append(attachmentString)
        string.append(NSAttributedString(string: String.init(" ") + self.text!))
        
        self.attributedText = string
    }
}
