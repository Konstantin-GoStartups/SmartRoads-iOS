//
//  ObjectExtensions.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 30.03.21.
//

import Foundation
import RealmSwift


extension Dictionary {
    
    /// Convert Dictionary to JSON string
    /// - Throws: exception if dictionary cannot be converted to JSON data or when data cannot be converted to UTF8 string
    /// - Returns: JSON string
    func toJson() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: self)
        if let string = String(data: data, encoding: .utf8) {
            return string
        }
        throw NSError(domain: "Dictionary", code: 1, userInfo: ["message": "Data cannot be converted to .utf8 string"])
    }
}

extension Object {
    func toDictionary() -> [String:AnyObject] {
        let properties = self.objectSchema.properties.map { $0.name }
        var dicProps = [String:AnyObject]()
        for (key, value) in self.dictionaryWithValues(forKeys: properties) {
            //key = key.uppercased()
            if let value = value as? ListBase {
                dicProps[key] = value.toArray1() as AnyObject
            } else if let value = value as? Object {
                dicProps[key] = value.toDictionary() as AnyObject
            } else {
                dicProps[key] = value as AnyObject
            }
        }
        return dicProps
    }
    
    func toDictionary2() -> NSDictionary {
        let properties = self.objectSchema.properties.map { $0.name }
        let dictionary = self.dictionaryWithValues(forKeys: properties)

        var mutabledic = NSMutableDictionary()
        mutabledic.setValuesForKeys(dictionary)

        for prop in self.objectSchema.properties as [Property] {
            // find lists
            if let objectClassName = prop.objectClassName  {
                if let nestedObject = self[prop.name] as? Object {
                    mutabledic.setValue(nestedObject.toDictionary2(), forKey: prop.name)
                } else if let nestedListObject = self[prop.name] as? ListBase {
                    var objects = [AnyObject]()
                    for index in 0..<nestedListObject._rlmArray.count  {
                        if let object = nestedListObject._rlmArray[index] as? Object {
                            objects.append(object.toDictionary2())
                        }
                    }
                    mutabledic.setObject(objects, forKey: prop.name as NSCopying)
                }
            }
        }
        return mutabledic
    }
}

extension ListBase {
    func toArray1() -> [AnyObject] {
        var _toArray = [AnyObject]()
        for i in 0..<self._rlmArray.count {
            let obj = unsafeBitCast(self._rlmArray[i], to: Object.self)
            _toArray.append(obj.toDictionary() as AnyObject)
        }
        return _toArray
    }
}
