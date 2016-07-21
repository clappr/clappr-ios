public class DateFormatter {
    private static let hourInSeconds:Double = 1 * 60 * 60
    
    public class func formatSeconds(totalSeconds: NSTimeInterval) -> String {
        let date = NSDate(timeIntervalSince1970: totalSeconds)
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.dateFormat = totalSeconds < hourInSeconds ? "mm:ss" : "HH:mm:ss"
        return formatter.stringFromDate(date)
    }
}