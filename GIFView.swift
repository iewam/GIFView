//
//  GIFView.swift
//  GifView
//
//  Created by Steven on 2018/7/8.
//  Copyright © 2018年 Steven. All rights reserved.
//

import UIKit
import ImageIO
import QuartzCore

class GIFView: UIView {
    
    var width : CGFloat {return self.frame.size.width}
    var height : CGFloat {return self.frame.size.height}
    private var imageArr : Array<CGImage> = []
    private var timeArr : Array<NSNumber> = []
    private var totalTime : Float = 0
    private var newSize : CGSize = CGSize.zero

    func showGIFImageWithLocalName(name : String) {
        let gifUrl = Bundle.main.url(forResource: name, withExtension: "gif")
        parseImage(url: gifUrl! as CFURL)
    }
    
    func showGIFImageFromNetWork(url : URL) {
        let fileName = String.md5String(string: url.absoluteString)
        let folderPtah = NSHomeDirectory() + "/Library/Caches/GIFView/"
       
        let fileManger = FileManager.default
        if !fileManger.fileExists(atPath: folderPtah) {
            do {
                try fileManger.createDirectory(atPath: folderPtah, withIntermediateDirectories: false, attributes: nil)
            } catch {}
        }
        
        let filePath = folderPtah + fileName + ".gif"
        let fileUrl = URL(fileURLWithPath: filePath)
        
        if  fileManger.fileExists(atPath: filePath) {
            parseImage(url: fileUrl as CFURL)
            print("from local")
        } else {
            let session = URLSession.shared
            let task = session.dataTask(with: url) { (data, resp, error) in
                if ((data) != nil) {
                    do {
                        try data?.write(to: fileUrl, options: Data.WritingOptions.atomicWrite)
                        DispatchQueue.main.async {
                            self.parseImage(url: fileUrl as CFURL)
                            print("from network")
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            task.resume()
        }
        
    }
    
    
    func parseImage(url:CFURL) {
        let gifSource = CGImageSourceCreateWithURL(url, nil)
        let imageCount = CGImageSourceGetCount(gifSource!)
        for i in 0 ..< imageCount {
            let imageRef = CGImageSourceCreateImageAtIndex(gifSource!, i, nil)
            imageArr.append(imageRef!)
            let properties = CGImageSourceCopyPropertiesAtIndex(gifSource!, i, nil) as NSDictionary?
         
            let imageWidth = properties![String(kCGImagePropertyPixelWidth)] as! NSNumber
            let imageHeight = properties![String(kCGImagePropertyPixelHeight)] as! NSNumber
            if CGFloat(imageWidth.floatValue/imageHeight.floatValue) != width/height {
                fitScale(imageWidth: CGFloat(imageWidth.floatValue), imageHeight: CGFloat(imageHeight.floatValue))
            }
            
            let gifDict = properties![String(kCGImagePropertyGIFDictionary)] as! NSDictionary
            let time = gifDict[String(kCGImagePropertyGIFUnclampedDelayTime)] as! NSNumber
            timeArr.append(time)
            totalTime += time.floatValue
        }
        showAnimation()
    }
    
    
    func fitScale(imageWidth : CGFloat, imageHeight : CGFloat) {
        var newWidth:CGFloat
        var newHeight:CGFloat
        if imageWidth/imageHeight > width/height {
            newWidth = width
            newHeight = width / (imageWidth/imageHeight)
        } else {
            newHeight = height;
            newWidth = height / (imageHeight/imageWidth)
        }
        
        let point : CGPoint = self.center
        newSize = CGSize(width: newWidth, height: newHeight)
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 3, animations: {
                
                self.frame.size = self.newSize
                self.center = point
            })
        }
        
    }
    
    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        print("draw")
//        self.frame.size = newSize
//    }
    
    func showAnimation() {
        let animation = CAKeyframeAnimation(keyPath: "contents")
        var keyTimes : Array<NSNumber> = []
        var current : Float = 0
        for time in timeArr {
            keyTimes.append(NSNumber(floatLiteral: Double(current/totalTime)))
            current += time.floatValue
        }
        animation.keyTimes = keyTimes
        animation.values = imageArr
        animation.duration = CFTimeInterval(totalTime)
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        self.layer.add(animation, forKey: "GIFView")
    }

}

extension String {
    
    static func md5String(string : String) -> String {
        return getMD5StringFromString(string: string)
    }
    
    private static func getMD5StringFromString(string : String) -> String {
        let str = string.cString(using: .utf8)
        let strlen = CC_LONG(string.lengthOfBytes(using: .utf8))
        let digeTlen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digeTlen)
        CC_MD5(str!, strlen, result)
        let hash = NSMutableString()
        for i in 0..<digeTlen {
            hash.appendFormat("%02x", result[i])
        }
        result.deallocate()
        return hash.copy() as! String
    }
}










