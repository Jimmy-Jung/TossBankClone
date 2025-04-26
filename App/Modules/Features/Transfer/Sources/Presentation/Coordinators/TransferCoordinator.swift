import Foundation
import UIKit
import CoordinatorModule
import SwiftUI

/// 송금 코디네이터 구현
public final class TransferCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let diContainer: TransferDIContainerProtocol
    private let sourceAccountId: String
    
    public weak var delegate: TransferCoordinatorDelegate?
    
    public init(navigationController: UINavigationController, 
                diContainer: TransferDIContainerProtocol,
                sourceAccountId: String) {
        self.navigationController = navigationController
        self.diContainer = diContainer
        self.sourceAccountId = sourceAccountId
    }
    
    public func start() {
        showTransferAmount()
    }
    
    // MARK: - 화면 전환 메서드
    
    private func showTransferAmount() {
        // 송금 금액 화면 뷰모델 생성
        let viewModel = TransferAmountViewModel(accountId: sourceAccountId)
        viewModel.onContinueButtonTapped = { [weak self] amount, receiverAccount in
            self?.showTransferConfirmation(amount: amount, receiverAccount: receiverAccount)
        }
        viewModel.onCancelButtonTapped = { [weak self] in
            self?.delegate?.transferCoordinatorDidCancel()
        }
        
        // SwiftUI 뷰를 UIKit 호스팅 컨트롤러로 래핑
        let transferView = TransferAmountView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: transferView)
        viewController.title = "송금하기"
        
        // 취소 버튼 추가
        let cancelButton = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        viewController.navigationItem.leftBarButtonItem = cancelButton
        
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    private func showTransferConfirmation(amount: Double, receiverAccount: BankAccount) {
        // 송금 확인 화면 뷰모델 생성
        let viewModel = TransferConfirmViewModel(
            sourceAccountId: sourceAccountId,
            amount: amount,
            receiverAccount: receiverAccount
        )
        viewModel.onTransferButtonTapped = { [weak self] in
            self?.showTransferResult(success: true)
        }
        viewModel.onCancelButtonTapped = { [weak self] in
            self?.showTransferAmount()
        }
        
        // SwiftUI 뷰를 UIKit 호스팅 컨트롤러로 래핑
        let confirmView = TransferConfirmView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: confirmView)
        viewController.title = "송금 확인"
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showTransferResult(success: Bool) {
        // 송금 결과 화면 뷰모델 생성
        let viewModel = TransferResultViewModel(success: success)
        viewModel.onDoneButtonTapped = { [weak self] in
            self?.delegate?.transferCoordinatorDidFinish()
        }
        
        // SwiftUI 뷰를 UIKit 호스팅 컨트롤러로 래핑
        let resultView = TransferResultView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: resultView)
        viewController.title = success ? "송금 완료" : "송금 실패"
        
        // 네비게이션 바 숨기기
        viewController.navigationItem.hidesBackButton = true
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    // MARK: - 액션 메서드
    
    @objc private func cancelButtonTapped() {
        delegate?.transferCoordinatorDidCancel()
    }
}

// MARK: - 뷰모델 임시 구현
// 실제 구현에서는 별도 파일로 분리되어야 함

class TransferAmountViewModel: ObservableObject {
    let accountId: String
    @Published var amount: String = ""
    @Published var memo: String = ""
    @Published var account: BankAccount?
    @Published var selectedReceiverAccount: BankAccount?
    @Published var recentAccounts: [BankAccount] = []
    @Published var showingAccountSelector = false
    
    var onContinueButtonTapped: ((Double, BankAccount) -> Void)?
    var onCancelButtonTapped: (() -> Void)?
    
    var isNextButtonEnabled: Bool {
        guard let amount = Double(amount.replacingOccurrences(of: ",", with: "")),
              let selectedAccount = selectedReceiverAccount else {
            return false
        }
        return amount > 0
    }
    
    init(accountId: String) {
        self.accountId = accountId
        loadAccount()
        loadRecentAccounts()
    }
    
    func loadAccount() {
        // 테스트 데이터
        account = BankAccount(id: accountId, bankName: "토스뱅크", accountNumber: "1234-56-7890123", balance: 1250000)
    }
    
    func loadRecentAccounts() {
        // 테스트 데이터
        recentAccounts = [
            BankAccount(id: "100", bankName: "신한은행", accountNumber: "110-123-456789", balance: 0),
            BankAccount(id: "101", bankName: "국민은행", accountNumber: "123-45-6789012", balance: 0),
            BankAccount(id: "102", bankName: "우리은행", accountNumber: "1002-456-789012", balance: 0)
        ]
    }
    
    func selectReceiver(_ account: BankAccount) {
        selectedReceiverAccount = account
        showingAccountSelector = false
    }
    
    func handleContinueButton() {
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: "")),
              let receiverAccount = selectedReceiverAccount else {
            return
        }
        
        onContinueButtonTapped?(amountValue, receiverAccount)
    }
    
    func handleCancel() {
        onCancelButtonTapped?()
    }
}

class TransferConfirmViewModel: ObservableObject {
    let sourceAccountId: String
    let amount: Double
    let receiverAccount: BankAccount
    @Published var sourceAccount: BankAccount?
    @Published var fee: Double = 0
    
    var onTransferButtonTapped: (() -> Void)?
    var onCancelButtonTapped: (() -> Void)?
    
    init(sourceAccountId: String, amount: Double, receiverAccount: BankAccount) {
        self.sourceAccountId = sourceAccountId
        self.amount = amount
        self.receiverAccount = receiverAccount
        loadSourceAccount()
    }
    
    func loadSourceAccount() {
        // 테스트 데이터
        sourceAccount = BankAccount(id: sourceAccountId, bankName: "토스뱅크", accountNumber: "1234-56-7890123", balance: 1250000)
    }
    
    func handleTransferButton() {
        onTransferButtonTapped?()
    }
    
    func handleCancelButton() {
        onCancelButtonTapped?()
    }
}

class TransferResultViewModel: ObservableObject {
    let success: Bool
    let transactionId: String
    
    var onDoneButtonTapped: (() -> Void)?
    
    init(success: Bool) {
        self.success = success
        self.transactionId = "T\(Int.random(in: 10000...99999))"
    }
    
    func handleDoneButton() {
        onDoneButtonTapped?()
    }
}

// MARK: - 모델 임시 구현
// 실제 구현에서는 도메인 모듈에 정의되어야 함

struct BankAccount: Identifiable {
    let id: String
    let bankName: String
    let accountNumber: String
    let balance: Double
}

// MARK: - 뷰 임시 구현
// 실제 구현에서는 별도 파일로 분리되어야 함

struct TransferAmountView: View {
    @ObservedObject var viewModel: TransferAmountViewModel
    @FocusState private var isAmountFieldFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 금액 입력 섹션
                VStack(spacing: 16) {
                    Text("얼마를 보낼까요?")
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(alignment: .center) {
                        Text("₩")
                            .font(.title)
                        
                        TextField("0", text: $viewModel.amount)
                            .font(.largeTitle)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .focused($isAmountFieldFocused)
                    }
                    .padding(.vertical, 8)
                    
                    Divider()
                    
                    if let account = viewModel.account {
                        HStack {
                            Text("잔액: \(formatCurrency(account.balance))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button("전액") {
                                viewModel.amount = String(format: "%.0f", account.balance)
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                }
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
                
                // 받는 계좌 선택 섹션
                VStack(spacing: 12) {
                    Text("어디로 보낼까요?")
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let account = viewModel.selectedReceiverAccount {
                        // 선택된 계좌 표시
                        ReceiverAccountRow(account: account)
                            .onTapGesture {
                                viewModel.showingAccountSelector = true
                            }
                    } else {
                        // 계좌 선택 버튼
                        Button(action: {
                            viewModel.showingAccountSelector = true
                        }) {
                            HStack {
                                Image(systemName: "person.crop.circle")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                Text("받을 계좌 선택하기")
                                    .font(.body)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(16)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(16)
                        }
                    }
                }
                
                // 메모 입력 섹션
                VStack(spacing: 8) {
                    Text("받는 분에게 표시될 메모")
                        .font(.body)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("(선택) 최대 20자", text: $viewModel.memo)
                        .padding(16)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                }
                
                Spacer()
                
                // 다음 버튼
                Button(action: {
                    viewModel.handleContinueButton()
                }) {
                    Text("다음")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isNextButtonEnabled ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!viewModel.isNextButtonEnabled)
                .padding(.top, 30)
            }
            .padding(16)
        }
        .onAppear {
            // 첫 화면 로드 시 금액 입력 필드에 포커스
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isAmountFieldFocused = true
            }
        }
        .sheet(isPresented: $viewModel.showingAccountSelector) {
            AccountSelectorView(
                accounts: viewModel.recentAccounts,
                onAccountSelected: { account in
                    viewModel.selectReceiver(account)
                }
            )
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₩"
        return formatter.string(from: NSNumber(value: amount)) ?? "₩0"
    }
}

struct TransferConfirmView: View {
    @ObservedObject var viewModel: TransferConfirmViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // 송금 정보 카드
            VStack(spacing: 16) {
                // 송금액
                VStack(spacing: 4) {
                    Text("송금액")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(formatCurrency(viewModel.amount))
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Divider()
                
                // 출금 계좌
                if let sourceAccount = viewModel.sourceAccount {
                    VStack(spacing: 4) {
                        Text("출금 계좌")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(sourceAccount.bankName) \(sourceAccount.accountNumber)")
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Divider()
                }
                
                // 입금 계좌
                VStack(spacing: 4) {
                    Text("입금 계좌")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("\(viewModel.receiverAccount.bankName) \(viewModel.receiverAccount.accountNumber)")
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if viewModel.fee > 0 {
                    Divider()
                    
                    // 수수료
                    VStack(spacing: 4) {
                        Text("수수료")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(formatCurrency(viewModel.fee))
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            
            // 안내 메시지
            Text("송금 내용을 확인한 후 송금 버튼을 눌러주세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // 버튼 영역
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.handleTransferButton()
                }) {
                    Text("송금하기")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    viewModel.handleCancelButton()
                }) {
                    Text("취소")
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
            }
        }
        .padding(16)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₩"
        return formatter.string(from: NSNumber(value: amount)) ?? "₩0"
    }
}

struct TransferResultView: View {
    @ObservedObject var viewModel: TransferResultViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // 성공/실패 아이콘
            Image(systemName: viewModel.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(viewModel.success ? .green : .red)
                .padding(.bottom, 16)
            
            // 메시지
            Text(viewModel.success ? "송금이 완료되었습니다" : "송금에 실패했습니다")
                .font(.title2)
                .fontWeight(.bold)
            
            if viewModel.success {
                Text("거래번호: \(viewModel.transactionId)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 완료 버튼
            Button(action: {
                viewModel.handleDoneButton()
            }) {
                Text("확인")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding(16)
    }
}

struct ReceiverAccountRow: View {
    let account: BankAccount
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(account.bankName)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(account.accountNumber)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct AccountSelectorView: View {
    let accounts: [BankAccount]
    let onAccountSelected: (BankAccount) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(accounts) { account in
                Button(action: {
                    onAccountSelected(account)
                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(account.bankName)
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Text(account.accountNumber)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("계좌 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
} 