import SwiftUI
import DomainModule
import SharedModule

public final class AccountListViewModel: AsyncViewModel {
    // Input 열거형 정의
    public enum Input {
        case viewDidLoad
        case refresh
        case selectAccount(id: String)
    }
    
    // Action 열거형 정의
    public enum Action {
        case fetchAccounts
        case updateAccountList([AccountEntity])
        case showAccountDetail(id: String)
    }
    
    // 상태 프로퍼티
    @Published var accounts: [AccountEntity] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var selectedAccountId: String?
    var onAccountSelected: ((String) -> Void)?
    
    private let fetchAccountsUseCase: FetchAccountsUseCaseProtocol
    
    public init(fetchAccountsUseCase: FetchAccountsUseCaseProtocol) {
        self.fetchAccountsUseCase = fetchAccountsUseCase
    }

// MARK: - AsyncViewModel
    public func transform(_ input: Input) async -> [Action] {
        switch input {
        case .viewDidLoad, .refresh:
            return [.fetchAccounts]
        case .selectAccount(let id):
            return [.showAccountDetail(id: id)]
        }
    }
    
    public func perform(_ action: Action) async throws {
        switch action {
        case .fetchAccounts:
            try await fetchAccounts()
        case .updateAccountList(let accounts):
            try await updateAccountList(accounts)
        case .showAccountDetail(let id):
            try await showAccountDetail(id: id)
        }
    }
    
    public func handleError(_ error: Error) async {
        self.error = error
        isLoading = false
        print("Error: \(error.localizedDescription)")
    }

    func fetchAccounts() async throws {
        isLoading = true
        error = nil
        
        let result = await fetchAccountsUseCase.execute()
        
        switch result {
        case .success(let fetchedAccounts):
            accounts = fetchedAccounts
            isLoading = false
        case .failure(let entityError):
            await handleError(entityError)
        }
    }
    
    func updateAccountList(_ accounts: [AccountEntity]) async throws {
        self.accounts = accounts
        isLoading = false
    }
    
    func showAccountDetail(id: String) async throws {
        selectedAccountId = id
        
        if let callback = onAccountSelected {
            await MainActor.run {
                callback(id)
            }
        }
    }
} 
