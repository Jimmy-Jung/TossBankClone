import Foundation
import UIKit
import CoordinatorModule
import SwiftUI

/// 계좌 코디네이터 구현
public final class AccountCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let diContainer: AccountDIContainerProtocol
    
    public weak var delegate: AccountCoordinatorDelegate?
    
    public init(navigationController: UINavigationController, diContainer: AccountDIContainerProtocol) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }
    
    public func start() {
        showAccountList()
    }
    
    // MARK: - 화면 전환 메서드
    
    private func showAccountList() {
        // 계좌 목록 뷰모델 생성
        let viewModel = AccountListViewModel()
        
        // SwiftUI 뷰를 UIKit 호스팅 컨트롤러로 래핑
        let accountListView = AccountListView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: accountListView)
        viewController.title = "계좌"
        
        // 네비게이션 바 아이템 설정
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsButtonTapped)
        )
        viewController.navigationItem.rightBarButtonItem = settingsButton
        
        // 탭 바 아이템 설정
        viewController.tabBarItem = UITabBarItem(
            title: "계좌",
            image: UIImage(systemName: "creditcard"),
            selectedImage: UIImage(systemName: "creditcard.fill")
        )
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func showAccountDetail(accountId: String) {
        // 계좌 상세 뷰모델 생성
        let viewModel = AccountDetailViewModel(accountId: accountId)
        viewModel.onTransferButtonTapped = { [weak self] in
            self?.delegate?.accountCoordinatorDidRequestTransfer(fromAccountId: accountId)
        }
        
        // SwiftUI 뷰를 UIKit 호스팅 컨트롤러로 래핑
        let accountDetailView = AccountDetailView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: accountDetailView)
        viewController.title = "계좌 상세"
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    // MARK: - 액션 메서드
    
    @objc private func settingsButtonTapped() {
        delegate?.accountCoordinatorDidRequestSettings()
    }
}

// MARK: - 뷰모델 임시 구현
// 실제 구현에서는 별도 파일로 분리되어야 함

class AccountListViewModel: ObservableObject {
    @Published var accounts: [Account] = []
    
    init() {
        // 테스트 데이터 로드
        loadMockData()
    }
    
    func loadMockData() {
        accounts = [
            Account(id: "1", name: "토스뱅크 통장", balance: 1250000),
            Account(id: "2", name: "비상금 계좌", balance: 5000000)
        ]
    }
}

class AccountDetailViewModel: ObservableObject {
    @Published var account: Account?
    @Published var transactions: [Transaction] = []
    
    var onTransferButtonTapped: (() -> Void)?
    
    let accountId: String
    
    init(accountId: String) {
        self.accountId = accountId
        loadAccount()
        loadTransactions()
    }
    
    func loadAccount() {
        // 테스트 데이터
        account = Account(id: accountId, name: "토스뱅크 통장", balance: 1250000)
    }
    
    func loadTransactions() {
        // 테스트 데이터
        transactions = [
            Transaction(id: "t1", description: "편의점", amount: -4500, date: Date()),
            Transaction(id: "t2", description: "급여", amount: 2500000, date: Date().addingTimeInterval(-86400*3))
        ]
    }
    
    func handleTransferTap() {
        onTransferButtonTapped?()
    }
}

// MARK: - 모델 임시 구현
// 실제 구현에서는 도메인 모듈에 정의되어야 함

struct Account: Identifiable {
    let id: String
    let name: String
    let balance: Double
}

struct Transaction: Identifiable {
    let id: String
    let description: String
    let amount: Double
    let date: Date
}

// MARK: - 뷰 임시 구현
// 실제 구현에서는 별도 파일로 분리되어야 함

struct AccountListView: View {
    @ObservedObject var viewModel: AccountListViewModel
    
    var body: some View {
        List(viewModel.accounts) { account in
            AccountRow(account: account)
        }
    }
}

struct AccountRow: View {
    let account: Account
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(account.name)
                    .font(.headline)
                Text(formatCurrency(account.balance))
                    .font(.subheadline)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₩"
        formatter.currencyDecimalSeparator = ","
        return formatter.string(from: NSNumber(value: amount)) ?? "₩0"
    }
}

struct AccountDetailView: View {
    @ObservedObject var viewModel: AccountDetailViewModel
    
    var body: some View {
        VStack {
            if let account = viewModel.account {
                // 계좌 정보
                AccountInfoCard(account: account)
                    .padding()
                
                // 송금 버튼
                Button(action: {
                    viewModel.handleTransferTap()
                }) {
                    Text("송금하기")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // 거래 내역 목록
                List(viewModel.transactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .navigationTitle("계좌 상세")
    }
}

struct AccountInfoCard: View {
    let account: Account
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(account.name)
                .font(.headline)
            
            Text(formatCurrency(account.balance))
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₩"
        formatter.currencyDecimalSeparator = ","
        return formatter.string(from: NSNumber(value: amount)) ?? "₩0"
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.description)
                    .font(.headline)
                
                Text(formatDate(transaction.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(formatCurrency(transaction.amount))
                .font(.subheadline)
                .foregroundColor(transaction.amount >= 0 ? .blue : .primary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₩"
        formatter.currencyDecimalSeparator = ","
        return formatter.string(from: NSNumber(value: amount)) ?? "₩0"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
} 