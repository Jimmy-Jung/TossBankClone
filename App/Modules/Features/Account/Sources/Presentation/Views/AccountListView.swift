import SwiftUI
import DomainModule
import DesignSystem

struct AccountListView: View {
    @StateObject var viewModel: AccountListViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let error = viewModel.error {
                VStack {
                    Text("계좌 정보를 불러오는데 실패했습니다")
                        .foregroundColor(.red)
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Button("다시 시도") {
                        Task {
                            viewModel.send(.refresh)
                        }
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }
            } else {
                List(viewModel.accounts, id: \.id) { account in
                    AccountRow(account: account)
                        .onTapGesture {
                            Task {
                                await viewModel.send(.selectAccount(id: account.id))
                            }
                        }
                }
                .listStyle(.plain)
                .refreshable {
                    viewModel.send(.refresh)
                }
            }
        }
        .navigationTitle("내 계좌")
        .task {
            viewModel.send(.viewDidLoad)
        }
    }
}

struct AccountRow: View {
    let account: AccountEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(account.name)
                .font(.headline)
            
            Text(account.number)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("\(formatCurrency(account.balance))원")
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding(.vertical, 8)
    }
    
    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: value as NSNumber) ?? "0"
    }
} 

// MARK: - 미리보기
struct AccountListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AccountListView(viewModel: AccountListViewModel(fetchAccountsUseCase: MockFetchAccountsUseCase()))
        }
    }
}

struct MockFetchAccountsUseCase: FetchAccountsUseCaseProtocol {
    func execute() async -> Result<[DomainModule.AccountEntity], DomainModule.EntityError> {
        return .success([
            AccountEntity(id: UUID().uuidString, name: "정준영", type: .savings, balance: 2000000, number: "2345-6789-0123", isActive: true, updatedAt: Date(), transactions: []),
            AccountEntity(id: UUID().uuidString, name: "김민수", type: .checking, balance: 1500000, number: "1234-5678-9012", isActive: true, updatedAt: Date(), transactions: [])
        ])
    }
}
