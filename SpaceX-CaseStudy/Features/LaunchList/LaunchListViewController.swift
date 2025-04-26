//
//  LaunchListViewController.swift
//  SpaceX-CaseStudy
//
//  Created by İhsan Akbay on 13.04.2025.
//

import Combine
import SnapKit
import UIKit

class LaunchListViewController: UIViewController {
    // MARK: - Properties
       
    private let viewModel = LaunchListViewModel()
    private var cancellables = Set<AnyCancellable>()
       
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Upcoming", "Past"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .systemBackground
        segmentedControl.selectedSegmentTintColor = .white
           
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.systemGray
        ], for: .normal)
           
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.label
        ], for: .selected)
           
        return segmentedControl
    }()
       
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.register(LaunchCell.self, forCellReuseIdentifier: "LaunchCell")
        return tableView
    }()
       
    private let refreshControl = UIRefreshControl()
       
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
       
    private let errorView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
       
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemRed
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
       
    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
       
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchLaunches()
    }
       
    // MARK: - Methods
       
    private func setupUI() {
        view.backgroundColor = .systemBackground
           
        title = "Launches"
        navigationController?.navigationBar.prefersLargeTitles = false
           
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorView)
           
        errorView.addSubview(errorLabel)
        errorView.addSubview(retryButton)
           
        setupConstraints()
           
        setupActions()
           
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
           
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
       
    private func setupConstraints() {
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
           
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
           
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(tableView)
        }
           
        errorView.snp.makeConstraints { make in
            make.center.equalTo(tableView)
            make.leading.trailing.equalToSuperview().inset(32)
        }
           
        errorLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(errorView)
        }
           
        retryButton.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(16)
            make.centerX.equalTo(errorView)
            make.bottom.equalTo(errorView)
        }
    }
       
    private func setupActions() {
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
    }
       
    private func setupBindings() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                   
                switch state {
                case .idle:
                    break
                case .loading:
                    self.showLoading()
                case .loaded(let launches):
                    self.hideLoading()
                    self.tableView.reloadData()
                       
                    if launches.isEmpty {
                        self.showEmptyState()
                    } else {
                        self.hideEmptyState()
                    }
                case .paginating:
                    self.refreshControl.endRefreshing()
                case .error(let error):
                    self.hideLoading()
                    self.refreshControl.endRefreshing()
                    self.showError(error)
                }
            }
            .store(in: &cancellables)
    }
       
    private func showLoading() {
        loadingIndicator.startAnimating()
        tableView.isHidden = true
        errorView.isHidden = true
    }
       
    private func hideLoading() {
        loadingIndicator.stopAnimating()
        refreshControl.endRefreshing()
        tableView.isHidden = false
    }
       
    private func showEmptyState() {
        errorView.isHidden = false
        errorLabel.text = "No launches found"
        retryButton.isHidden = true
    }
       
    private func hideEmptyState() {
        errorView.isHidden = true
        retryButton.isHidden = false
    }
       
    private func showError(_ error: NetworkRequestError) {
        tableView.isHidden = true
        errorView.isHidden = false
           
        switch error {
        case .serverError, .error5xx:
            errorLabel.text = "Server error. Please try again later."
        case .timeOut, .urlSessionFailed:
            errorLabel.text = "Connection error. Please check your internet connection."
        default:
            errorLabel.text = "Something went wrong. Please try again."
        }
    }
       
    // MARK: - Actions
       
    @objc private func segmentChanged() {
        let newType: LaunchListType = segmentedControl.selectedSegmentIndex == 0 ? .upcoming : .past
        viewModel.switchListType(to: newType)
    }
       
    @objc private func refreshData() {
        viewModel.refreshLaunches()
    }
       
    @objc private func retryButtonTapped() {
        viewModel.fetchLaunches()
    }
}

extension LaunchListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewModel.state {
        case .loaded(let launches):
            return launches.count
        case .paginating(let launches):
            return launches.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LaunchCell", for: indexPath) as? LaunchCell else {
            return UITableViewCell()
        }
        
        var launches: [Launch] = []
        
        switch viewModel.state {
        case .loaded(let loadedLaunches):
            launches = loadedLaunches
        case .paginating(let loadedLaunches):
            launches = loadedLaunches
        default:
            break
        }
        
        if indexPath.row < launches.count {
            let launch = launches[indexPath.row]
            cell.configure(with: launch, dateFormatter: viewModel.formatDate)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var launches: [Launch] = []
        
        switch viewModel.state {
        case .loaded(let loadedLaunches):
            launches = loadedLaunches
        case .paginating(let loadedLaunches):
            launches = loadedLaunches
        default:
            return
        }
        
        if indexPath.row < launches.count {
            let launch = launches[indexPath.row]
            if let launchId = launch.id {
                let detailVC = LaunchDetailViewController(launchId: launchId)
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if position > contentHeight - scrollViewHeight - 100 {
            viewModel.loadMoreLaunches()
        }
    }
}
