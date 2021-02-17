//
//  GithubEndpointViewController.swift
//  MougiTDD
//
//  Created by Julian on 2021/2/15.
//  数据展示页

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

class GithubEndpointViewController: UIViewController {
    // MARK: - UIKit Property
    /// 列表页面
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Varies Property
    /// 数据源
    private var dataSource = BehaviorSubject(value: Array<[String: Any]>())
    /// 回收站
    private let bag = DisposeBag()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // 1. 设置头部, 显示 endpoint 的数据条数
        Observable.collection(from: DataManager.shared.endpoints!)
            .map { return $0.first }
            .subscribe { (event) in
                switch event {
                case .next(let element):
                    self.title = element?.timeStamp.getDateNowString()
                case .error(_): break
                case .completed: break
                }
            }.disposed(by: bag)
        
        // 2. 数据库的数据更新触发页面数据刷新
        Observable.changeset(from: DataManager.shared.endpoints!, synchronousStart: true)
            .subscribe(onNext: { (results, changeset) in
                if let first = results.first, let obj = first.response?.obj {
                    // 1. 数据处理
                    let encoder = JSONEncoder()
                    let data = try! encoder.encode(obj)
                    let dict: Dictionary = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String, Any>
                    let items = dict.map {
                        [$0.key: $0.value]
                    }
                    // 2.刷新数据
                    self.dataSource.asObserver().onNext(items)
                }
            }).disposed(by: bag)
        
        // MARK:- 数据源绑定cell
        self.dataSource
            .bind(to: self.tableView.rx.items(cellIdentifier: "GithubEndpointCell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = "KEY: - \(element.keys.first ?? "")"
                cell.detailTextLabel?.text = "VALUE: -  \(element.values.first ?? "")"
            }.disposed(by: bag)
    }
}
