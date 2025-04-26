//
//  LaunchDetailViewModel.swift
//  SpaceX-CaseStudy
//
//  Created by İhsan Akbay on 13.04.2025.
//

import Combine
import Foundation

enum LaunchDetailState {
    case idle
    case loading
    case loaded(Launch)
    case error(NetworkRequestError)
}

final class LaunchDetailViewModel {
    // MARK: - Properties

    private let networkService: LaunchDetailNetworkServiceProtocol
    @Published private(set) var state: LaunchDetailState = .idle
    private let launchId: String
    private var cancellables = Set<AnyCancellable>()
    private var countdownTimer: Timer?
    @Published private(set) var countdownString: String = ""
    @Published private(set) var showCountdown = false
    
    init(networkService: LaunchDetailNetworkServiceProtocol = LaunchDetailNetworkService(),
         launchId: String)
    {
        self.networkService = networkService
        self.launchId = launchId
    }
    
    deinit {
        countdownTimer?.invalidate()
    }
    
    // MARK: - Methods

    func fetchLaunchDetails() {
        state = .loading
        
        networkService.getDetail(id: launchId)
            .sink { [weak self] completion in
                guard let self = self else { return }
                
                if case .failure(let error) = completion {
                    self.state = .error(error)
                }
            } receiveValue: { [weak self] launch in
                guard let self = self else { return }
                
                self.state = .loaded(launch)
                if let dateUnix = launch.dateUnix, let upcoming = launch.upcoming, upcoming {
                    self.startCountdownTimer(launchDate: Date(timeIntervalSince1970: TimeInterval(dateUnix)))
                }
            }
            .store(in: &cancellables)
    }
    
    private func startCountdownTimer(launchDate: Date) {
        updateCountdown(launchDate: launchDate)
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateCountdown(launchDate: launchDate)
        }
    }
    
    private func updateCountdown(launchDate: Date) {
        let currentDate = Date()
        let calendar = Calendar.current
        
        if currentDate >= launchDate {
            countdownString = "Launched"
            showCountdown = false
            countdownTimer?.invalidate()
            return
        }
        
        let components = calendar.dateComponents([.day, .hour, .minute, .second],
                                                 from: currentDate,
                                                 to: launchDate)
        
        let days = components.day ?? 0
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0
        
        countdownString = String(format: "%02d : %02d : %02d : %02d",
                                 days, hours, minutes, seconds)
        showCountdown = true
    }
    
    func formatLaunchDate(from dateUnix: Int?) -> String {
        guard let dateUnix = dateUnix else { return "-" }
        
        let date = Date(timeIntervalSince1970: TimeInterval(dateUnix))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        
        return formatter.string(from: date)
    }
}
