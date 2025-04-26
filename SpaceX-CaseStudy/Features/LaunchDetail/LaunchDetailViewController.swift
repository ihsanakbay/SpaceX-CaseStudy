//
//  LaunchDetailViewController.swift
//  SpaceX-CaseStudy
//
//  Created by İhsan Akbay on 13.04.2025.
//
//

import Combine
import SnapKit
import UIKit

class LaunchDetailViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel: LaunchDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let missionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
        imageView.layer.cornerRadius = 22
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        return imageView
    }()
    
    private let missionNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let launchDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let countdownContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let countdownTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        label.text = "LAUNCH DATE"
        return label
    }()
    
    private let dateStringLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private let countdownStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    private let detailsGridView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // Grid cells
    private let landingAttemptContainer = UIView()
    private let landingSuccessContainer = UIView()
    private let landingTypeContainer = UIView()
    private let flightNumberContainer = UIView()
    private let upcomingContainer = UIView()
    private let datePrecisionContainer = UIView()
    
    private let linksContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let youtubeButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray5.cgColor
        return button
    }()
    
    private let presskitButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray5.cgColor
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init(launchId: String) {
        self.viewModel = LaunchDetailViewModel(launchId: launchId)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchLaunchDetails()
    }
    
    // MARK: - Methods

    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupHierarchy()
        setupConstraints()
        setupDetailGrids()
        setupExternalLinks()
        setupCountdownUI()
        setupActions()
    }
    
    // MARK: - NavBar
    
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButton
    }
    
    // MARK: - Constraints
    
    private func setupHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(missionImageView)
        contentView.addSubview(missionNameLabel)
        contentView.addSubview(launchDateLabel)
        contentView.addSubview(countdownContainerView)
        contentView.addSubview(detailsGridView)
        contentView.addSubview(linksContainer)
        
        countdownContainerView.addSubview(countdownTitleLabel)
        countdownContainerView.addSubview(dateStringLabel)
        countdownContainerView.addSubview(countdownStackView)
        
        linksContainer.addSubview(youtubeButton)
        linksContainer.addSubview(presskitButton)
        
        view.addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        missionImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(44)
        }
        
        missionNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(missionImageView)
            make.leading.equalTo(missionImageView.snp.trailing).offset(12)
        }
        
        if viewModel.showCountdown {
            countdownContainerView.snp.makeConstraints { make in
                make.top.equalTo(launchDateLabel.snp.bottom).offset(16)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.equalTo(80)
            }
            
            countdownTitleLabel.snp.makeConstraints { make in
                make.top.leading.equalToSuperview().offset(12)
            }
            
            dateStringLabel.snp.makeConstraints { make in
                make.leading.equalTo(countdownTitleLabel.snp.trailing).offset(8)
                make.centerY.equalTo(countdownTitleLabel)
            }
            
            countdownStackView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(4)
            }
        } else {
            launchDateLabel.snp.makeConstraints { make in
                make.top.equalTo(missionImageView.snp.bottom).offset(8)
                make.leading.equalToSuperview().inset(20)
            }
        }
        
        detailsGridView.snp.makeConstraints { make in
            if viewModel.showCountdown {
                make.top.equalTo(countdownContainerView.snp.bottom).offset(24)
            } else {
                make.top.equalTo(launchDateLabel.snp.bottom).offset(24)
            }
            
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        linksContainer.snp.makeConstraints { make in
            make.top.equalTo(detailsGridView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        youtubeButton.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(64)
        }
        
        presskitButton.snp.makeConstraints { make in
            make.top.equalTo(youtubeButton.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(64)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Grids
    
    private func setupDetailGrids() {
        detailsGridView.addSubview(landingAttemptContainer)
        detailsGridView.addSubview(landingSuccessContainer)
        detailsGridView.addSubview(landingTypeContainer)
        detailsGridView.addSubview(flightNumberContainer)
        detailsGridView.addSubview(upcomingContainer)
        detailsGridView.addSubview(datePrecisionContainer)
        
        // Row 1
        landingAttemptContainer.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5).offset(-8)
            make.height.equalTo(72)
        }
        
        landingSuccessContainer.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5).offset(-8)
            make.height.equalTo(72)
            make.leading.equalTo(landingAttemptContainer.snp.trailing).offset(16)
        }
        
        // Row 2
        landingTypeContainer.snp.makeConstraints { make in
            make.top.equalTo(landingAttemptContainer.snp.bottom).offset(16)
            make.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5).offset(-8)
            make.height.equalTo(72)
        }
        
        flightNumberContainer.snp.makeConstraints { make in
            make.top.equalTo(landingSuccessContainer.snp.bottom).offset(16)
            make.trailing.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5).offset(-8)
            make.height.equalTo(72)
            make.leading.equalTo(landingTypeContainer.snp.trailing).offset(16)
        }
        
        // Row 3
        upcomingContainer.snp.makeConstraints { make in
            make.top.equalTo(landingTypeContainer.snp.bottom).offset(16)
            make.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5).offset(-8)
            make.height.equalTo(72)
            make.bottom.equalToSuperview()
        }
        
        datePrecisionContainer.snp.makeConstraints { make in
            make.top.equalTo(flightNumberContainer.snp.bottom).offset(16)
            make.trailing.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5).offset(-8)
            make.height.equalTo(72)
            make.leading.equalTo(upcomingContainer.snp.trailing).offset(16)
            make.bottom.equalToSuperview()
        }
        
        [landingAttemptContainer, landingSuccessContainer, landingTypeContainer,
         flightNumberContainer, upcomingContainer, datePrecisionContainer].forEach { container in
            container.layer.cornerRadius = 8
            container.layer.borderWidth = 1
            container.layer.borderColor = UIColor.systemGray5.cgColor
            container.backgroundColor = .systemBackground
        }
    }
    
    private func setupGridCell(container: UIView, title: String, value: String) {
        container.subviews.forEach { $0.removeFromSuperview() }
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.distribution = .fillProportionally
        stackView.alignment = .leading
        
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        titleLabel.textColor = .systemGray
        titleLabel.text = title
        
        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        valueLabel.textColor = .label
        valueLabel.text = value
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)
                
        container.addSubview(stackView)
                
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
    
    // MARK: - Links

    private func setupExternalLinks() {
        let youtubeIconContainer = UIView()
        youtubeIconContainer.backgroundColor = .systemRed
        youtubeIconContainer.layer.cornerRadius = 20
        
        let youtubeIcon = UIImageView()
        youtubeIcon.image = UIImage(systemName: "play.circle.fill")
        youtubeIcon.tintColor = .white
        youtubeIcon.contentMode = .scaleAspectFit
        
        let youtubeLabel = UILabel()
        youtubeLabel.text = "YouTube"
        youtubeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        youtubeLabel.textColor = .label
        
        let youtubeChevron = UIImageView()
        youtubeChevron.image = UIImage(systemName: "chevron.right")
        youtubeChevron.tintColor = .systemGray3
        youtubeChevron.contentMode = .scaleAspectFit
        
        youtubeButton.addSubview(youtubeIconContainer)
        youtubeIconContainer.addSubview(youtubeIcon)
        youtubeButton.addSubview(youtubeLabel)
        youtubeButton.addSubview(youtubeChevron)
        
        youtubeIconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(40)
        }
        
        youtubeIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(24)
        }
        
        youtubeLabel.snp.makeConstraints { make in
            make.leading.equalTo(youtubeIconContainer.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
        
        youtubeChevron.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }
        
        let presskitIconContainer = UIView()
        presskitIconContainer.backgroundColor = .systemRed
        presskitIconContainer.layer.cornerRadius = 20
        
        let presskitIcon = UIImageView()
        presskitIcon.image = UIImage(systemName: "doc.fill")
        presskitIcon.tintColor = .white
        presskitIcon.contentMode = .scaleAspectFit
        
        let presskitLabel = UILabel()
        presskitLabel.text = "Presskit"
        presskitLabel.font = .systemFont(ofSize: 14, weight: .medium)
        presskitLabel.textColor = .label
        
        let presskitChevron = UIImageView()
        presskitChevron.image = UIImage(systemName: "chevron.right")
        presskitChevron.tintColor = .systemGray3
        presskitChevron.contentMode = .scaleAspectFit
        
        presskitButton.addSubview(presskitIconContainer)
        presskitIconContainer.addSubview(presskitIcon)
        presskitButton.addSubview(presskitLabel)
        presskitButton.addSubview(presskitChevron)
        
        presskitIconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(40)
        }
        
        presskitIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(24)
        }
        
        presskitLabel.snp.makeConstraints { make in
            make.leading.equalTo(presskitIconContainer.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
        
        presskitChevron.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }
    }
    
    // MARK: - Countdown
    
    private func setupCountdownUI() {
        countdownStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                
        let countdownUnits = ["Hour", "Minute", "Second"]
                
        for (index, labelText) in countdownUnits.enumerated() {
            let unitContainer = UIView()
                    
            let valueLabel = UILabel()
            valueLabel.text = "00"
            valueLabel.font = .systemFont(ofSize: 18, weight: .bold)
            valueLabel.textColor = .white
            valueLabel.textAlignment = .center
            valueLabel.tag = 100 + index
                    
            let unitLabel = UILabel()
            unitLabel.text = labelText
            unitLabel.font = .systemFont(ofSize: 12, weight: .regular)
            unitLabel.textColor = .white
            unitLabel.textAlignment = .center
                    
            unitContainer.addSubview(valueLabel)
            unitContainer.addSubview(unitLabel)
                    
            valueLabel.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
            }
                    
            unitLabel.snp.makeConstraints { make in
                make.top.equalTo(valueLabel.snp.bottom).offset(2)
                make.leading.trailing.bottom.equalToSuperview()
            }
                    
            countdownStackView.addArrangedSubview(unitContainer)
                    
            // Add separator except for the last item
            if index < countdownUnits.count - 1 {
                let separatorLabel = UILabel()
                separatorLabel.text = ":"
                separatorLabel.font = .systemFont(ofSize: 18, weight: .bold)
                separatorLabel.textColor = .white
                separatorLabel.textAlignment = .center
                countdownStackView.addArrangedSubview(separatorLabel)
            }
        }
    }
    
    private func setupActions() {
        youtubeButton.addTarget(self, action: #selector(youtubeButtonTapped), for: .touchUpInside)
        presskitButton.addTarget(self, action: #selector(presskitButtonTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                
                switch state {
                case .idle, .loading:
                    self.loadingIndicator.startAnimating()
                    self.scrollView.isHidden = true
                case .loaded:
                    self.loadingIndicator.stopAnimating()
                    self.scrollView.isHidden = false
                    self.updateUI()
                case .error(let error):
                    self.loadingIndicator.stopAnimating()
                    self.showError(error)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$countdownString
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countdownString in
                guard let self = self else { return }
                self.updateCountdownValues(countdownString)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Updates
    
    private func updateUI() {
        guard case .loaded(let launch) = viewModel.state else { return }
        
        title = launch.upcoming == true ? "Upcoming Launch" : "Past Launch"
        missionNameLabel.text = launch.name ?? "-"
        
        if let dateUnix = launch.dateUnix {
            let formattedDate = viewModel.formatLaunchDate(from: dateUnix)
            launchDateLabel.text = "Launch Date: \(formattedDate)"
            dateStringLabel.text = formattedDate
            
            let launchDate = Date(timeIntervalSince1970: TimeInterval(dateUnix))
            let isInFuture = launchDate > Date()
            countdownContainerView.isHidden = !isInFuture
        } else {
            launchDateLabel.text = "Launch Date: -"
            dateStringLabel.text = "-"
            countdownContainerView.isHidden = true
        }
        
        if let originalImage = UIImage(named: "rocket") {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 24, height: 24))
            let resizedImage = renderer.image { _ in
                originalImage.draw(in: CGRect(x: 0, y: 0, width: 24, height: 24))
            }
            missionImageView.image = resizedImage
        }
        missionImageView.tintColor = .white
        missionImageView.contentMode = .center
        
        updateGridCells(with: launch)
        
        updateExternalLinksAvailability(with: launch)
    }
    
    private func updateGridCells(with launch: Launch) {
        setupGridCell(
            container: landingAttemptContainer,
            title: "Landing Attempt",
            value: String(launch.cores?.first?.legs ?? false)
        )
        
        let landingSuccessValue: String
        landingSuccessValue = "-"
        setupGridCell(
            container: landingSuccessContainer,
            title: "Landing Success",
            value: landingSuccessValue
        )
        
        setupGridCell(
            container: landingTypeContainer,
            title: "Landing Type",
            value: (launch.cores?.first?.gridfins ?? false) ? "RTLS" : "-"
        )
        
        setupGridCell(
            container: flightNumberContainer,
            title: "Flight Number",
            value: launch.flightNumber != nil ? String(launch.flightNumber!) : "Unknown"
        )
        
        setupGridCell(
            container: upcomingContainer,
            title: "Upcoming",
            value: String(launch.upcoming ?? false)
        )
        
        setupGridCell(
            container: datePrecisionContainer,
            title: "Date Precision",
            value: (launch.datePrecision ?? "hour").capitalized
        )
    }
    
    private func updateExternalLinksAvailability(with launch: Launch) {
        let hasYoutubeLink = launch.links?.youtubeId != nil
        youtubeButton.isEnabled = hasYoutubeLink
        youtubeButton.alpha = hasYoutubeLink ? 1.0 : 0.5
        
        let hasPresskitLink = launch.links?.webcast != nil
        presskitButton.isEnabled = hasPresskitLink
        presskitButton.alpha = hasPresskitLink ? 1.0 : 0.5
    }
    
    private func updateCountdownValues(_ countdownString: String) {
        if countdownString.isEmpty || countdownString == "Launched" {
            // Set default values if no countdown or already launched
            for i in 0..<3 {
                if let label = countdownStackView.viewWithTag(100 + i) as? UILabel {
                    label.text = "00"
                }
            }
            return
        }
                
        let components = countdownString.components(separatedBy: " : ")
                
        if components.count >= 4 {
            if let hourLabel = countdownStackView.viewWithTag(100) as? UILabel {
                hourLabel.text = components[1]
            }
                    
            if let minuteLabel = countdownStackView.viewWithTag(101) as? UILabel {
                minuteLabel.text = components[2]
            }
                    
            if let secondLabel = countdownStackView.viewWithTag(102) as? UILabel {
                secondLabel.text = components[3]
            }
        } else {
            for i in 0..<3 {
                if let label = countdownStackView.viewWithTag(100 + i) as? UILabel {
                    label.text = "00"
                }
            }
        }
    }
    
    private func showError(_ error: NetworkRequestError) {
        let alert = UIAlertController(
            title: "Error",
            message: getErrorMessage(for: error),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.fetchLaunchDetails()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func getErrorMessage(for error: NetworkRequestError) -> String {
        switch error {
        case .serverError, .error5xx:
            return "Server error. Please try again later."
        case .timeOut, .urlSessionFailed:
            return "Connection error. Please check your internet connection."
        default:
            return "Something went wrong. Please try again."
        }
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func youtubeButtonTapped() {
        guard case .loaded(let launch) = viewModel.state,
              let webcastUrl = launch.links?.webcast,
              let url = URL(string: webcastUrl)
        else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    @objc private func presskitButtonTapped() {
        guard case .loaded(let launch) = viewModel.state,
              let presskitUrl = launch.links?.webcast,
              let url = URL(string: presskitUrl)
        else {
            return
        }
        
        UIApplication.shared.open(url)
    }
}
