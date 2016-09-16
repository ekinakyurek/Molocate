import Foundation

extension IntervalType {
    public func random() -> Bound {
        let range = (self.end as! Int) - (self.start as! Int)
        let randomValue = (Int(arc4random_uniform(UINT32_MAX)) / Int(UINT32_MAX)) * range + (self.start as! Int)
        return randomValue as! Bound
    }
}