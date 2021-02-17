//
//  DataManagerTests.swift
//  MougiTDDTests
//
//  Created by Julian on 2021/2/15.
//

import XCTest
import RxSwift
import RxRealm
import RealmSwift
import RxBlocking
@testable import GithubEndpointTDD

class DataManagerTests: XCTestCase {
    
    let manager = DataManager.shared
    // 初始化数据
    let api = GithubAPI.endpoint
    let channel = ChannelType.countDown

    override func setUpWithError() throws {
        // 删除数据库
        let realm = try! Realm()
        try! realm.write {
          realm.deleteAll()
        }
        self.setUp()
    }

    override func tearDownWithError() throws {
    }
    
    // 1. 获取网络数据
    func testGetGithubEndpointData() throws {
        // given
        // when
        let observable = manager.getGithubEndpointData(type: channel, api: api)
        let result = observable.toBlocking()
        // then
        XCTAssertEqual(try result.first()?.response?.code, 200, "\(api.baseURL) + \(api.path) response status code is not 200") // 校验状态码
        XCTAssertEqual(try result.first()?.channel, channel.rawValue, "input channel & output channel is difference") // 校验入参出参渠道是否一致
        XCTAssertNotNil(try result.first()?.response?.obj, "\(api.baseURL) + \(api.path) response nil") // 校验是否有数据返回
    }
    
    // 2. 存储网络数据
    func testStorageEndpointData() throws {
        // given
        let observable = manager.getGithubEndpointData(type: channel, api: api)
        let result = try observable.toBlocking().first()
        var successToSave = false
        // when
        manager.netEndpoints.onNext(result!)
        // then
        manager.endpoints?.toArray().forEach { (obj) in
            if obj.timeStamp == result!.timeStamp {
                successToSave = true
            }
            XCTAssertTrue(successToSave, "endpoint data fail to save into realm!")
        }
    }
    
    // 3. 获取缓存数据
    func testGetEndpointCacheData() throws {
        // given
        // 删除数据库
        let realm = try! Realm()
        try! realm.write {
          realm.deleteAll()
        }
        // 1.获取数据库
        do {
            let noEndpoints = try manager.getEndpointCacheData()
            XCTAssertEqual(noEndpoints.count, 0, "success to link realm!")
        } catch DataError.getRealmFailure {
            XCTAssertThrowsError(DataError.getRealmFailure)
        }
        // 存储数据
        let observable = manager.getGithubEndpointData(type: channel, api: api)
        let result = try observable.toBlocking().first()
        manager.netEndpoints.onNext(result!)
        // when
        // 2.获取数据库
        do {
            let endpoints = try manager.getEndpointCacheData()
            XCTAssertNotNil(endpoints, "failure to get realm data!")
        } catch DataError.getRealmFailure {
            XCTAssertThrowsError(DataError.getRealmFailure)
        }
        // then
    }

    // FIXME: - 第一次启动时可能会出现超时错误
    func testBeginInterval5sRequest() throws {
        // 删除数据库
        let realm = try! Realm()
        try! realm.write {
          realm.deleteAll()
        }
        let expectation = self.expectation(description: "github api interval 5 seconds")
        var times = 0
        let bag = DisposeBag()
        //
        manager.beginInterval5sRequest()
        manager.netEndpoints.subscribe { (event) in
            if times >= 2 {
                expectation.fulfill()
            }
            times += 1
        }.disposed(by: bag)
        waitForExpectations(timeout: 15) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    // MARK: - 性能测试
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
        }
    }

}
