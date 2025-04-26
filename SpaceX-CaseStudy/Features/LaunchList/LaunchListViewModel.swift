//
//  LaunchListViewModel.swift
//  SpaceX-CaseStudy
//
//  Created by İhsan Akbay on 13.04.2025.
//

import Combine
import Foundation

enum LaunchListState {
    case idle
    case loading
    case loaded([Launch])
    case paginating([Launch])
    case error(NetworkRequestError)
}

enum LaunchListType {
    case upcoming
    case past
}

final class LaunchListViewModel {
    // MARK: - Properties

    private let networkService: LaunchListNetworkServiceProtocol
        
    @Published private(set) var state: LaunchListState = .idle
    @Published private(set) var listType: LaunchListType = .upcoming
    
    private var currentPage = 1
    private var totalPages = 1
    private var hasNextPage = false
    private var cancellables = Set<AnyCancellable>()
    private var launches: [Launch] = []
        
    init(networkService: LaunchListNetworkServiceProtocol = LaunchListNetworkService()) {
        self.networkService = networkService
    }
        
    // MARK: - Public Methods
        
    func fetchLaunches() {
        state = .loading
            
        switch listType {
        case .upcoming:
            fetchUpcomingLaunches()
        case .past:
            fetchPastLaunches()
        }
    }
        
    func refreshLaunches() {
        currentPage = 1
        launches = []
            
        fetchLaunches()
    }
        
    func loadMoreLaunches() {
        guard hasNextPage, case .loaded = state else { return }
            
        currentPage += 1
        state = .paginating(launches)
            
        let paginationRequest = PaginationRequest(
            page: currentPage,
            limit: 10,
            upcoming: listType == .upcoming
        )
            
        networkService.queryLaunches(with: paginationRequest)
            .sink { [weak self] completion in
                guard let self = self else { return }
                    
                if case .failure(let error) = completion {
                    self.state = .error(error)
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                    
                if let newLaunches = response.docs {
                    self.launches.append(contentsOf: newLaunches)
                    self.state = .loaded(self.launches)
                        
                    self.totalPages = response.totalPages ?? 1
                    self.hasNextPage = response.hasNextPage ?? false
                } else {
                    self.state = .loaded(self.launches)
                }
            }
            .store(in: &cancellables)
    }
        
    func switchListType(to type: LaunchListType) {
        guard type != listType else { return }
        listType = type
        currentPage = 1
        launches = []
            
        fetchLaunches()
    }
        
    func formatDate(from dateUnix: Int?) -> String {
        guard let dateUnix = dateUnix else { return "" }
            
        let date = Date(timeIntervalSince1970: TimeInterval(dateUnix))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd - HH:mm"
            
        return formatter.string(from: date)
    }
        
    // MARK: - Private Methods
        
    private func fetchUpcomingLaunches() {
        let paginationRequest = PaginationRequest(page: currentPage, limit: 10, upcoming: true)
            
        networkService.queryLaunches(with: paginationRequest)
            .sink { [weak self] completion in
                guard let self = self else { return }
                    
                if case .failure(let error) = completion {
                    self.state = .error(error)
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                    
                if let newLaunches = response.docs {
                    self.launches = newLaunches
                    self.state = .loaded(self.launches)
                        
                    self.totalPages = response.totalPages ?? 1
                    self.hasNextPage = response.hasNextPage ?? false
                } else {
                    self.state = .loaded([])
                }
            }
            .store(in: &cancellables)
    }
        
    private func fetchPastLaunches() {
        let paginationRequest = PaginationRequest(page: currentPage, limit: 10, upcoming: false)
            
        networkService.queryLaunches(with: paginationRequest)
            .sink { [weak self] completion in
                guard let self = self else { return }
                    
                if case .failure(let error) = completion {
                    self.state = .error(error)
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                    
                if let newLaunches = response.docs {
                    self.launches = newLaunches
                    self.state = .loaded(self.launches)
                        
                    self.totalPages = response.totalPages ?? 1
                    self.hasNextPage = response.hasNextPage ?? false
                } else {
                    self.state = .loaded([])
                }
            }
            .store(in: &cancellables)
    }
}
