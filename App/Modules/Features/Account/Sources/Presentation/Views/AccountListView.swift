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
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.send(.selectAccount(id: account.id))
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
