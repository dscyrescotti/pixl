//
//  SettingsViewController.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import XCoordinator

class SettingsViewController: UIViewController, AppBarInjectable {
    
    private let rowItems = BehaviorRelay<[[RowItem]]>(value: [[.init(text: "Profile", route: .profile)], [.init(text: "Log out", route: .logout)]])
    private let bag = DisposeBag()
    
    internal var appBar: AppBar = .init()
    private let backButton = BarButton(systemName: "arrow.backward")
    private let orientationChange = PublishRelay<Orientation>()
    
    var router: UnownedRouter<HomeRoute>?
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<Void, RowItem>> { datasource, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath)
        cell.textLabel?.text = item.text
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private let tableView: UITableView = .init(frame: .zero, style: .grouped).then {
        $0.backgroundColor = .systemGroupedBackground
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "row")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
        
        addAppBar()
    }

}

extension SettingsViewController {
    func setUp() {
        title = "Settings"
        view.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        registerLayout()
    }
    
    func bind() {
        rowItems
            .map { items -> [SectionModel<Void, RowItem>] in
                items.map { SectionModel<Void, RowItem>(model: (), items: $0) }
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                let item = rowItems.value[indexPath.section][indexPath.row]
                tableView.deselectRow(at: indexPath, animated: true)
                switch item.route {
                case .logout:
                    let alert = UIAlertController(title: "Are you sure to log out?", message: nil, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    action.setValue(UIColor.systemRed, forKey: "titleTextColor")
                    alert.addAction(action)
                    alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { [unowned self] action in
                        router?.trigger(item.route)
                    }))
                    present(alert, animated: true)
                case .profile:
                    router?.trigger(item.route)
                default:
                    break
                }
            })
            .disposed(by: bag)
        
        let orientation = orientationChange
            .distinctUntilChanged()
        
        orientation
            .bind(to: backButton.orientationChange)
            .disposed(by: bag)
        
        backButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        orientationChange.accept(size.orientation(portrait: Orientation.portrait, landscape: .landscape))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpBarButtons()
    }
    
    func setUpBarButtons() {
        orientationChange.accept(view.orientation(portrait: Orientation.portrait, landscape: .landscape))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
}

struct RowItem {
    let text: String
    let route: HomeRoute
}
