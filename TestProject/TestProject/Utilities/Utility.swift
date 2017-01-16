//
//  Utility.swift
//  TestProject
//
//  Created by Sudhansu Singh on 6/4/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import NVActivityIndicatorView
import Firebase

class Utility{
    
    // MARK: Class Methods
    static var activityIndicatorView : NVActivityIndicatorView?
    
    // get class name of an object
    class func classNameAsString(obj: Any) -> String {
        return String(obj.dynamicType).componentsSeparatedByString("__").last!
    }
    // string to date
    
    class func convertDateFormater(date: String) -> NSDate {
        var birthday : NSDate? = nil
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = kDateFormatter
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        birthday = dateFormatter.dateFromString(date)
        return birthday!
    }
    
    // date to time interval
    
    class func getTimeInterval(date: String)->NSTimeInterval{
        
        return convertDateFormater(date).timeIntervalSince1970
    }
    
    // MARK: Sorting arrays
    class func sortArrayDate(array:[PostEntity])-> [NSManagedObject]{
        let newArray = array.sort ({
            (obj1, obj2) in
            let p1 = obj1 as PostEntity
            let p2 = obj2 as PostEntity
            return p1.p_created_time!.compare(p2.p_created_time!) == .OrderedDescending
        })
        return newArray
    }
    
    class func fetchPriceAndLocation(message:String)->(Int, String){
            var array : [String]?
            array = message.lines
            if array?.count > 2 {
                let priceAndLoc  = array![1].characters.split{$0 == "-"}.map(String.init)
                if priceAndLoc.count > 1 {
                    let price = priceAndLoc[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    let loc = priceAndLoc[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    return (getNumberFromString(price), loc)
                }
            }
        return (0,kBlankString)
    }
    
    // create actibity indicator
    class func createActivityIndicator(view:UIView){
        let frame = CGRect(x: view.frame.width/2, y:view.frame.height/2, width: 30.0, height: 30.0)
        self.activityIndicatorView = NVActivityIndicatorView(frame: frame,
                                                            type: NVActivityIndicatorType(rawValue: 19)!)
        self.activityIndicatorView!.color = UIColor.redColor()
        
        view.addSubview(self.activityIndicatorView!)
        self.activityIndicatorView!.startAnimation()
        //Utility.createActivityIndicator(self.view).startAnimation()
    }
    // stop activity indicator
    class func stopActivityAnimating() {
        self.activityIndicatorView?.stopAnimation()
        self.activityIndicatorView?.removeFromSuperview()

    }
    
    // check user is logged in or not
    class func checkUserIsLoggedIn() -> Bool{
        var flag:Bool = false
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                flag = true
                
            } else {
                // User is not signed in
                flag = false
            }
        }
        return flag

    }
    // convert NSTimeInterval to day/date an time
    
    class func parseTime(time: NSTimeInterval) ->NSDateComponents{
        let date2 = NSDate.init(timeInterval: time, sinceDate: NSDate())
        
        // Get conversion to months, days, hours, minutes
        let unitFlags: NSCalendarUnit = [.Hour, .Day, .Month, .Year, .Weekday]
        
        let breakdownInfo = NSCalendar.currentCalendar().components(unitFlags, fromDate: NSDate(), toDate: date2, options: NSCalendarOptions.MatchFirst)
        
        return breakdownInfo
    }
    
    
}

func getNumberFromString(str:String) ->Int{
    if str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString == "free"{
        return -1
    }
    let stringArray = str.componentsSeparatedByCharactersInSet(
        NSCharacterSet.decimalDigitCharacterSet().invertedSet)
    let newString :String? = stringArray.joinWithSeparator("")
    if let newString = newString{
        let p :Int? = Int(newString)
        if let p = p{
            return p
        }
    }
    return 0
    
}
// MARK: Extensions

public extension String {
    
    subscript (r: Range<Int>) -> String {
        let range = self.startIndex.advancedBy(r.startIndex) ... self.startIndex.advancedBy(r.endIndex-1)
        return self.substringWithRange(range)
    }
    var lines:[String] {
        var result:[String] = []
        enumerateLines{ result.append($0.line) }
        return result
    }
    var length: Int {
        return characters.count
    }
 }

public extension UIColor{
    
    class func colorWithHexString(hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        
        // Convert hex string to an integer
        let hexint = Int(self.intFromHexString(hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
  class  func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: NSScanner = NSScanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = NSCharacterSet(charactersInString: "#")
        // Scan hex value
        scanner.scanHexInt(&hexInt)
        return hexInt
    }
}

enum NSComparisonResult : Int {
    case OrderedAscending
    case OrderedSame
    case OrderedDescending
}

extension NSRange {
    func toRange(string: String) -> Range<String.Index> {
        let startIndex = string.startIndex.advancedBy(location)
        let endIndex = string.startIndex.advancedBy(length)
        return startIndex..<endIndex
    }
}

// shake animation of UIView
extension UIView {
    func shake(d:String) {
        var animation = CAKeyframeAnimation()
        if d == "X"{
            animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        }
        else{
            animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        }
        
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 1
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.addAnimation(animation, forKey: "shake")
    }
}
// date format
extension NSDate {
    
    static func getBeautyToday(date:NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM hh:mm a','EEEE"
        return dateFormatter.stringFromDate(date)
    }
    
}
// append at beginning
extension Array{
    mutating func appendAtBeginning(newItem : Element){
        let copy = self
        self = []
        self.append(newItem)
        self.appendContentsOf(copy)
    }
    
}
// number from string
extension String {
    
    var numberValue:NSNumber? {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        return formatter.numberFromString(self)
    }
}

// md5 extension for string

extension String  {
    var md5: String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.dealloc(digestLen)
        
        return String(format: hash as String)
    }
}

// Ordered set values : Array

extension Array where Element: Equatable {
    var orderedSetValue: Array  {
        return reduce([]){ $0.contains($1) ? $0 : $0 + [$1] }
    }
}