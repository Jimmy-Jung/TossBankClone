import SwiftUI
import DomainModule
import CoordinatorModule

/// 송금 화면 조정자
public final class TransferCoordinator: ObservableObject, Coordinator {
    // MARK: - 라우트 정의
    public enum Route {
        case transfer(accountId: String)
        case transferComplete(result: TransferResult)
    }
    
    // MARK: - 속성
    @Published public var path = NavigationPath()
    private let diContainer: TransferDIContainer
    
    // MARK: - 생성자
    public init(diContainer: TransferDIContainer) {
        self.diContainer = diContainer
    }
    
    // MARK: - Coordinator 메서드
    @ViewBuilder
    public func build(route: Route) -> some View {
        switch route {
        case .transfer(let accountId):
            makeTransferView(accountId: accountId)
            
        case .transferComplete(let result):
            makeTransferCompleteView(result: result)
        }
    }
    
    public func navigate(to route: Route) {
        path.append(route)
    }
    
    public func navigateBack() {
        path.removeLast()
    }
    
    public func navigateToRoot() {
        path.removeLast(path.count)
    }
    
    // MARK: - 뷰 팩토리 메서드
    private func makeTransferView(accountId: String) -> some View {
        let viewModel = TransferViewModel(
            accountId: accountId,
            transferUseCase: diContainer.makeTransferFundsUseCase(),
            fetchFrequentAccountsUseCase: diContainer.makeFetchFrequentAccountsUseCase(),
            fetchAccountDetailsUseCase: diContainer.makeFetchAccountDetailsUseCase()
        )
        
        return TransferView(viewModel: viewModel)
            .environmentObject(self)
    }
    
    private func makeTransferCompleteView(result: TransferResult) -> some View {
        // 송금 완료 화면은 향후 구현
        EmptyView()
    }
}

/// 송금 모듈 의존성 컨테이너
public protocol TransferDIContainer {
    func makeTransferFundsUseCase() -> TransferFundsUseCaseProtocol
    func makeFetchFrequentAccountsUseCase() -> FetchFrequentAccountsUseCaseProtocol
    func makeFetchAccountDetailsUseCase() -> FetchAccountDetailsUseCaseProtocol
} 