//
//  DataManager.swift
//  MougiTDD
//
//  Created by Julian on 2021/2/15.
//
import Foundation
import Moya
import RxRealm
import RealmSwift
import RxSwift
import RxCocoa

/// 错误类型（包含网络请求、数据库数据获取等错误）
internal enum DataError: Error {
    case responseValueIsNone // 返回数据为空，数据异常
    case getRealmFailure // 获取数据库失败
}

/// 数据管理类
class DataManager {
    // MARK: - Property
    /// 用于控制网络请求串行处理（模拟控制定时器和下拉事件不冲突）
    let serialStorageQueue = DispatchQueue(label: "queueSerial", qos: .default)
    
    /// 网络请求提供者
    let provider = MoyaProvider<GithubAPI>()
    
    /// 数据源
    var endpoints: Results<NetObject>?
    
    /// 网络请求返回的数据，监听并存入数据库
    let netEndpoints = PublishSubject<NetObject>()
    
    /// 回收站
    let bag = DisposeBag()
    
    // MARK: - Initialize
    /// 创建单例数据管理类
    static let shared = DataManager()
    init() {
        self.endpoints = try! getEndpointCacheData()
        // 监听网络数据的变化
        self.netEndpoints
            .map { $0 }
            .bind(to: Realm.rx.add(onError: { elements, error in
                if let elements = elements {
                    print("Error \(error.localizedDescription) while saving objects \(String(describing: elements))")
                } else {
                    print("Error \(error.localizedDescription) while opening realm.")
                }
            })).disposed(by: bag)
    }
    
    // MARK: - Public Methods
    // 获取数据库缓存数据集合
    internal func getEndpointCacheData() throws -> Results<NetObject> {
        do {
            let realm = try Realm()
            let objects = realm.objects(NetObject.self)
            if objects.count > 0 {
                return objects.sorted(byKeyPath: "timeStamp", ascending: false)
            } else {
                return objects
            }
        } catch  {
            throw DataError.getRealmFailure
        }
    }
    
    internal func getGithubEndpointData(type: ChannelType,api: GithubAPI) -> Observable<NetObject> {
        return Observable.create { [weak self] (observer: AnyObserver<NetObject>) -> Disposable in
            // 获取网络数据
            self?.provider.request(api, callbackQueue: self?.serialStorageQueue, progress: nil, completion: { response in
                guard response.error == nil else {
                    observer.onError(response.error!)
                    return
                }
                
                guard let value = response.value else { // 返回参数为空
                    observer.onError(DataError.responseValueIsNone)
                    return
                }
                
                // 请求信息
                let request = RequestObj()
                request.url = value.request?.url?.absoluteString ?? ""
                request.method = value.request?.httpMethod ?? ""
                // 数据转模型
                let decoder = JSONDecoder()
                let endpoint: EndpointModel = try! decoder.decode(EndpointModel.self, from: value.data)
                // 响应信息
                let responseObj = ResponseObj()
                responseObj.code = value.response?.statusCode ?? 0
                responseObj.obj = endpoint
                // 网络节点模型
                let netObj = NetObject()
                if type == ChannelType.refreshDown { // 下拉刷新数据
                    netObj.channel = 1
                } else { // 定时器数据
                    netObj.channel = 0
                }
                netObj.request = request
                netObj.response = responseObj
                // 1. 发送事件
                observer.onNext(netObj)
                // 2. 完成
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
    
    // MARK: - Private Methods
    public func beginInterval5sRequest() {
        Observable<Int>
            .timer(0.0, period: 5.0, scheduler: MainScheduler.instance)
            .flatMap { _ in
                self.getGithubEndpointData(type:ChannelType.countDown ,api: GithubAPI.endpoint)//.toArray()
            }
            .retry(3) // 错误重试
            .subscribe { [weak self] event in
                switch event {
                case .next(let value):
                    self?.netEndpoints.onNext(value)
                case .error(let error):
                    print(error)
                case .completed:
                    print("5 seconds interval to request github endpoint completed!")
                }
            }.disposed(by: bag)
    }
}
