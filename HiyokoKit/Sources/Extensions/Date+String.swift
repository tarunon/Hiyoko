//
//  Date+String.swift
//  Hiyoko
//
//  Created by tarunon on 2017/05/05.
//  Copyright © 2017年 tarunon. All rights reserved.
//

import Foundation

extension Date {
    private struct Formatter {
        static let year: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        static let month: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd"
            return formatter
        }()
        static let day: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd HH:mm"
            return formatter
        }()
        static let hour: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        }()
        static func minuteAgo(date: Date, since: Date) -> String {
            let dif = Int((since.timeIntervalSince1970 - date.timeIntervalSince1970) / 60.0)
            return "\(dif) m"
        }
        static func secondAgo(date: Date, since: Date) -> String {
            let dif = Int((since.timeIntervalSince1970 - date.timeIntervalSince1970))
            return "\(dif) s"
        }
    }
    func label(since: Date) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let d1 = calendar.dateComponents(in: .current, from: self)
        let d2 = calendar.dateComponents(in: .current, from: self)
        guard d1.year == d2.year else {
            return Formatter.year.string(from: self)
        }
        guard d1.month == d2.month else {
            return Formatter.month.string(from: self)
        }
        guard d1.day == d2.day else {
            return Formatter.day.string(from: self)
        }
        guard (since.timeIntervalSince1970 - self.timeIntervalSince1970) < 60 * 60 else {
            return Formatter.hour.string(from: self)
        }
        guard (since.timeIntervalSince1970 - self.timeIntervalSince1970) < 60 else {
            return Formatter.minuteAgo(date: self, since: since)
        }
        return Formatter.secondAgo(date: self, since: since)
    }
}
