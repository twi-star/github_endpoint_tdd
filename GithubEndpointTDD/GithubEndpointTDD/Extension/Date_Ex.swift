//
//  Date_Ex.swift
//  MougiTDD
//
//  Created by Julian on 2021/2/16.
//  

import Foundation

extension Date {
    func getDateNowString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}
