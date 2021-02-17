//
//  EndpointHistoryViewController.swift
//  MougiTDD
//
//  Created by Julian on 2021/2/15.
//  数据请求历史页

import UIKit
import RxSwift
import RxRealm
import RealmSwift
import MJRefresh

class EndpointHistoryViewController: UIViewController {
    // MARK: - UIKit Property
    /// 列表页面
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Varies Property
    /// 数据源
    private var dataSource = BehaviorSubject<Results<NetObject>>(value: DataManager.shared.endpoints!)
    
    /// 刷新头部
    let header = MJRefreshNormalHeader()
    
    /// 回收站
    let bag = DisposeBag()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // 1. 设置头部, 显示 endpoint 的数据条数
        Observable.collection(from: DataManager.shared.endpoints!)
            .map { results in "endpoint count: \(results.count)" }
            .subscribe { event in
                self.title = event.element
            }
            .disposed(by: bag)
        
        // 设置下拉刷新
        self.tableView.mj_header = self.header
        self.header.setRefreshingTarget(self, refreshingAction: #selector(self.loadNewData))
        
        // 监听数据变化
        Observable.changeset(from: DataManager.shared.endpoints!)
            .observeOn(MainScheduler.instance) // 主队列
            .subscribe(onNext: { [weak self] results, changes in
                if let changes = changes { // tableView 局部刷新
                    self?.tableView.applyChangeset(changes)
                    if results.count > 1 { // 刷新第二个, 刷新颜色
                        self?.tableView.reloadRows(at: [IndexPath.init(row: 1, section: 0)], with: .none)
                    }
                }
                else {
                    self?.tableView.reloadData()
                }
            })
            .disposed(by: bag)
    }
    
    // MARK: - Event Methods
    @objc func loadNewData() {
        DataManager.shared.getGithubEndpointData(type: .refreshDown ,api: .endpoint)
            .observeOn(MainScheduler.instance) // 主队列
            .subscribe({ result in
                switch result {
                case .next(let next):
                    DataManager.shared.netEndpoints.onNext(next)
                case .error(let error):
                    print(error)
                case .completed:
                    print("completed!")
                }
                DispatchQueue.main.async {
                    self.tableView.mj_header?.endRefreshing()
                }
            }).disposed(by: bag)
    }
}

extension EndpointHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return try! self.dataSource.value().count
    }
    
    // 刷新数据
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 获取cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "EndpointHistoryCell")!
        
        // 获取数据
        let endpoint = try! self.dataSource.value()[indexPath.row]
        cell.textLabel?.text = "TIME: -  \(endpoint.timeStamp.getDateNowString())"
        let channel = (endpoint.channel == 0 ? "定时器" : "下拉刷新")
        cell.detailTextLabel?.text = "URL: - \(endpoint.request?.url ?? "")  数据来源: \(channel)"
        return cell
    }
    
    // 修改颜色
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            cell.backgroundColor = UIColor.yellow
        } else {
            cell.backgroundColor = UIColor.white
        }
    }
}

extension UITableView {
    /// 处理数据变更
    func applyChangeset(_ changes: RealmChangeset) {
        beginUpdates()
        deleteRows(at: changes.deleted.map { IndexPath(row: $0, section: 0) }, with: .right)
        insertRows(at: changes.inserted.map { IndexPath(row: $0, section: 0) }, with: .right)
        reloadRows(at: changes.updated.map { IndexPath(row: $0, section: 0) }, with: .right)
        endUpdates()
    }
}
