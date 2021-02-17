//
//  GithubAPI.swift
//  MougiTDD
//
//  Created by Julian on 2021/2/16.
//

import UIKit
import Moya

/// Github的api接口
public enum GithubAPI {
    case endpoint
    case other
}

extension GithubAPI: TargetType {
    // baseUrl，可根据环境切换
    public var baseURL: URL {
        #if DEBUG // 判断是否在测试环境下
        return URL(string: "https://api.github.com")!
        #else
        return URL(string: "https://api.github.com")!
        #endif
    }
    
    /// 拼接于baseUrl的path
    public var path: String {
        switch self {
        case .endpoint:
            return ""
        default:
            return ""
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Moya.Method {
        switch self {
        case .endpoint:
            return .get
        default:
            return .get
        }
    }
    
    /// Provides stub data for use in testing.
    public var sampleData: Data {
        return "{}".data(using: .utf8)!
    }
    
    /// The type of HTTP task to be performed.
    public var task: Task {
        //FIXME: 一般需要修改添加参数，暂时设置为var
        var param: [String : Any] = [:]
        switch self {
        case .endpoint:
            
            break
        default:
            return .requestPlain
        }
        return .requestParameters(parameters: param, encoding: URLEncoding.default)
    }
    
    /// The type of validation to perform on the request. Default is `.none`.
    public var validationType: ValidationType {
        // 目前只考虑200..<300
        return .none
    }
    
    /// The headers to be used in the request.
    public var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
