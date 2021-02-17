//
//  NetObject.swift
//  MougiTDD
//
//  Created by Julian on 2021/2/15.
//

import Foundation
import RealmSwift

/// 数据来源
public enum ChannelType: Int {
    case countDown = 0 // 倒计时
    case refreshDown = 1 // 刷新
}

/// 缓存结构体
class NetObject: Object, Codable {
    
    /// 设备uuid，正常项目采用用户手机号或者唯一标识
    @objc dynamic var id = UUID().uuidString
    
    /// 数据渠道，默认为定时器
    @objc dynamic var channel: Int = 0
    
    /// 请求信息
    @objc dynamic var request: RequestObj?
    
    /// 响应信息
    @objc dynamic var response: ResponseObj?
    
    /// 时间戳，用于区分每次请求
    @objc dynamic var timeStamp: Date = Date()
    
    /// 重写realm的primary key
    override static func primaryKey() -> String? {
        return "id"
    }
}

/// 请求体信息
class RequestObj: Object, Codable {
    
    /// 请求的url
    @objc dynamic var url: String = ""
    
    /// 请求方法（GET | POST | DELETE ....)
    @objc dynamic var method: String = ""
}


/// 响应体信息
class ResponseObj: Object, Codable {
    
    /// 返回码
    @objc dynamic var code: Int = 0
    
    /// 返回数据
    @objc dynamic var obj: EndpointModel?
}
