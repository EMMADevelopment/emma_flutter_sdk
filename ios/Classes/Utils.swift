class Utils {
    
    class func isValidField(_ field: Any?) -> Bool {
        if !isNil(field) {
            if let str = field as? String, str.isEmpty {
               return false
            }
            return true
        }
        return false
    }

    class func isNil(_ value: Any?) -> Bool {
        guard let value = value else {
            return true
        }
        
        if  (value is NSNull) {
            return true
        }
        
        return false
    }
}