// import Foundation
// import DomainModule
// import Combine
// import SharedModule
// 
// /// 송금 화면 ViewModel
// public final class TransferViewModel {
//     // MARK: - Input & Action
//     public enum Input {
//         case viewDidLoad
//         case backButtonTapped
//         case closeButtonTapped
//         case amountChanged(String)
//         case maxAmountTapped
//         case selectReceiverTapped
//         case receiverSelected(FrequentAccount)
//         case memoChanged(String)
//         case continueButtonTapped
//     }
//     
//     public enum Action {
//         case loadInitialData
//         case handleAmountInput(String)
//         case setMaxAmount
//         case showAccountSelector
//         case selectReceiver(FrequentAccount)
//         case updateMemo(String)
//         case initiateTransfer
//     }
//     
//     // MARK: - 상태
//     @Published var amount: Decimal = 0
//     @Published var formattedAmount: String = ""
//     @Published var amountError: String? = nil
//     @Published var sourceAccount: AccountDomain? = nil
//     @Published var receiverAccount: FrequentAccount? = nil
//     @Published var memo: String = ""
//     @Published var isLoading: Bool = false
//     @Published var showAccountSelector: Bool = false
//     @Published var recentAccounts: [FrequentAccount] = []
//     @Published var error: DomainError? = nil
//     
//     var isNextButtonEnabled: Bool {
//         amount > 0 && receiverAccount != nil && amountError == nil && !isLoading
//     }
//     
//     var formattedBalance: String {
//         guard let account = sourceAccount else { return "0원" }
//         return formatCurrency(account.balance)
//     }
//     
//     private func formatCurrency(_ value: Decimal) -> String {
//         let formatter = NumberFormatter()
//         formatter.numberStyle = .currency
//         formatter.currencySymbol = "₩"
//         formatter.maximumFractionDigits = 0
//         
//         return formatter.string(from: value as NSDecimalNumber) ?? "₩0"
//     }
//     
//     // MARK: - 의존성
//     private let transferUseCase: TransferFundsUseCaseProtocol
//     private let fetchFrequentAccountsUseCase: FetchFrequentAccountsUseCaseProtocol
//     private let fetchAccountDetailsUseCase: FetchAccountDetailsUseCaseProtocol
//     private let accountId: String
//     
//     // MARK: - 생성자
//     public init(
//         accountId: String,
//         transferUseCase: TransferFundsUseCaseProtocol,
//         fetchFrequentAccountsUseCase: FetchFrequentAccountsUseCaseProtocol,
//         fetchAccountDetailsUseCase: FetchAccountDetailsUseCaseProtocol
//     ) {
//         self.accountId = accountId
//         self.transferUseCase = transferUseCase
//         self.fetchFrequentAccountsUseCase = fetchFrequentAccountsUseCase
//         self.fetchAccountDetailsUseCase = fetchAccountDetailsUseCase
//     }
// }
// 
// // MARK: - AsyncViewModel
// extension TransferViewModel: AsyncViewModel {
//     public nonisolated func transform(_ input: Input) async -> [Action] {
//         switch input {
//         case .viewDidLoad:
//             return [.loadInitialData]
//         case .backButtonTapped, .closeButtonTapped:
//             return [] // 네비게이션 처리는 외부에서 수행
//         case .amountChanged(let input):
//             return [.handleAmountInput(input)]
//         case .maxAmountTapped:
//             return [.setMaxAmount]
//         case .selectReceiverTapped:
//             return [.showAccountSelector]
//         case .receiverSelected(let account):
//             return [.selectReceiver(account)]
//         case .memoChanged(let memo):
//             return [.updateMemo(memo)]
//         case .continueButtonTapped:
//             return [.initiateTransfer]
//         }
//     }
//     
//     public func perform(_ action: Action) async throws {
//         switch action {
//         case .loadInitialData:
//             try await loadInitialData()
//         case .handleAmountInput(let input):
//             try await handleAmountInput(input)
//         case .setMaxAmount:
//             try await setMaxAmount()
//         case .showAccountSelector:
//             try await showAccountSelector()
//         case .selectReceiver(let account):
//             try await selectReceiver(account)
//         case .updateMemo(let memo):
//             try await updateMemo(memo)
//         case .initiateTransfer:
//             try await initiateTransfer()
//         }
//     }
//     
//     public func handleError(_ error: Error) async {
//         if let domainError = error as? DomainError {
//             self.error = domainError
//         } else {
//             self.error = .unknown(error)
//         }
//         isLoading = false
//     }
// }
// 
// // MARK: - 내부 메서드
// private extension TransferViewModel {
//     func loadInitialData() async throws {
//         isLoading = true
//         
//         // 1. 계좌 상세 조회
//         let accountResult = await fetchAccountDetailsUseCase.execute(accountId: accountId)
//         
//         switch accountResult {
//         case .success(let accountDetails):
//             sourceAccount = accountDetails.account
//         case .failure(let error):
//             self.error = error
//         }
//         
//         // 2. 자주 쓰는 계좌 목록 조회
//         let frequentAccountsResult = await fetchFrequentAccountsUseCase.execute()
//         
//         switch frequentAccountsResult {
//         case .success(let accounts):
//             recentAccounts = accounts
//         case .failure(let error):
//             print("자주 쓰는 계좌 조회 실패: \(error)")
//         }
//         
//         isLoading = false
//     }
//     
//     func handleAmountInput(_ input: String) async throws {
//         // 숫자만 필터링
//         let filteredInput = input.filter { $0.isNumber }
//         
//         // 빈 문자열이면 0으로 처리
//         if filteredInput.isEmpty {
//             amount = 0
//             formattedAmount = ""
//             amountError = nil
//             return
//         }
//         
//         // 숫자로 변환
//         if let amount = Decimal(string: filteredInput) {
//             self.amount = amount
//             
//             // 포맷팅 (천 단위 구분자)
//             let formatter = NumberFormatter()
//             formatter.numberStyle = .decimal
//             formatter.maximumFractionDigits = 0
//             formattedAmount = formatter.string(from: amount as NSDecimalNumber) ?? ""
//             
//             // 오류 체크: 잔액 충분한지
//             validateAmount(amount)
//         }
//     }
//     
//     func validateAmount(_ amount: Decimal) {
//         guard let account = sourceAccount else { return }
//         
//         if amount <= 0 {
//             amountError = "금액을 입력해주세요"
//         } else if amount > account.balance {
//             amountError = "잔액이 부족합니다"
//         } else if amount > 5000000 {
//             amountError = "1회 송금한도(500만원)를 초과했습니다"
//         } else {
//             amountError = nil
//         }
//     }
//     
//     func setMaxAmount() async throws {
//         guard let account = sourceAccount else { return }
//         
//         // 계좌 잔액과 한도(500만원) 중 작은 값으로 설정
//         let maxAmount = min(account.balance, 5000000)
//         amount = maxAmount
//         
//         // 포맷팅
//         let formatter = NumberFormatter()
//         formatter.numberStyle = .decimal
//         formatter.maximumFractionDigits = 0
//         formattedAmount = formatter.string(from: maxAmount as NSDecimalNumber) ?? ""
//         
//         // 오류 체크
//         validateAmount(maxAmount)
//     }
//     
//     func showAccountSelector() async throws {
//         showAccountSelector = true
//     }
//     
//     func selectReceiver(_ account: FrequentAccount) async throws {
//         receiverAccount = account
//         showAccountSelector = false
//     }
//     
//     func updateMemo(_ memo: String) async throws {
//         self.memo = memo
//     }
//     
//     func initiateTransfer() async throws {
//         guard isNextButtonEnabled,
//               let sourceAccount = sourceAccount,
//               let receiverAccount = receiverAccount else {
//             return
//         }
//         
//         isLoading = true
//         
//         let result = await transferUseCase.execute(
//             fromAccountId: sourceAccount.id,
//             toAccountNumber: receiverAccount.accountNumber,
//             amount: amount,
//             description: memo
//         )
//         
//         isLoading = false
//         
//         switch result {
//         case .success(let transferResult):
//             // 송금 성공 - 송금 완료 화면으로 이동은 호출자에서 처리
//             print("송금 성공: \(transferResult)")
//         case .failure(let error):
//             self.error = error
//         }
//     }
// }
// 
// // MARK: - 공개 인터페이스
// extension TransferViewModel {
//     public func sendAction(_ input: Input) {
//         Task {
//             await send(input)
//         }
//     }
// } 
