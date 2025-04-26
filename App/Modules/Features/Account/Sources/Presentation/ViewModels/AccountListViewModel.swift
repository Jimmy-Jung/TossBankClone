// import Foundation
// import SwiftUI
// import DomainModule
// import SharedModule
// 
// final class AccountListViewModel {
//     // Input 열거형 정의
//     enum Input {
//         case viewDidLoad
//         case refresh
//         case selectAccount(id: String)
//     }
//     
//     // Action 열거형 정의
//     enum Action {
//         case fetchAccounts
//         case updateAccountList([AccountEntity])
//         case showAccountDetail(id: String)
//     }
//     
//     // 상태 프로퍼티
//     @Published var accounts: [AccountEntity] = []
//     @Published var isLoading: Bool = false
//     @Published var error: Error?
//     @Published var selectedAccountId: String?
//     
//     private let fetchAccountsUseCase: FetchAccountsUseCaseProtocol
//     
//     init(fetchAccountsUseCase: FetchAccountsUseCaseProtocol) {
//         self.fetchAccountsUseCase = fetchAccountsUseCase
//     }
// }
// 
// // MARK: - AsyncViewModel
// extension AccountListViewModel: AsyncViewModel {
//     nonisolated func transform(_ input: Input) async -> [Action] {
//         switch input {
//         case .viewDidLoad, .refresh:
//             return [.fetchAccounts]
//         case .selectAccount(let id):
//             return [.showAccountDetail(id: id)]
//         }
//     }
//     
//     func perform(_ action: Action) async throws {
//         switch action {
//         case .fetchAccounts:
//             try await fetchAccounts()
//         case .updateAccountList(let accounts):
//             try await updateAccountList(accounts)
//         case .showAccountDetail(let id):
//             try await showAccountDetail(id: id)
//         }
//     }
//     
//     func handleError(_ error: Error) async {
//         self.error = error
//         isLoading = false
//         print("Error: \(error.localizedDescription)")
//     }
// }
// 
// // MARK: - 내부 메서드
// private extension AccountListViewModel {
//     func fetchAccounts() async throws {
//         isLoading = true
//         error = nil
//         
//         let result = await fetchAccountsUseCase.execute()
//         
//         switch result {
//         case .success(let fetchedAccounts):
//             accounts = fetchedAccounts
//             isLoading = false
//         case .failure(let entityError):
//             await handleError(entityError)
//         }
//     }
//     
//     func updateAccountList(_ accounts: [AccountEntity]) async throws {
//         self.accounts = accounts
//         isLoading = false
//     }
//     
//     func showAccountDetail(id: String) async throws {
//         selectedAccountId = id
//         // 여기서 coordinator를 사용하여 화면 전환도 가능
//     }
// } 
