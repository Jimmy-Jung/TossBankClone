// import SwiftUI
// import DesignSystem
// import DomainModule
// 
// /// 송금 화면
// public struct TransferView: View {
//     // MARK: - 속성
//     @ObservedObject private var viewModel: TransferViewModel
//     @FocusState private var isAmountFieldFocused: Bool
//     @Environment(\.presentationMode) private var presentationMode
//     @Environment(\.typographyStyle) private var typography
//     
//     // MARK: - 생성자
//     public init(viewModel: TransferViewModel) {
//         self.viewModel = viewModel
//     }
//     
//     // MARK: - 바디
//     public var body: some View {
//         ZStack {
//             ColorTokens.Background.primary
//                 .ignoresSafeArea()
//             
//             VStack(spacing: 0) {
//                 // 네비게이션 바
//                 navigationBar
//                 
//                 ScrollView {
//                     VStack(spacing: 24) {
//                         // 금액 입력 섹션
//                         amountInputSection
//                         
//                         // 받는 계좌 선택 섹션
//                         receiverSection
//                         
//                         // 메모 입력 섹션
//                         memoSection
//                         
//                         Spacer()
//                     }
//                     .padding(.horizontal, 20)
//                     .padding(.top, 20)
//                 }
//                 
//                 // 하단 버튼
//                 continueButton
//             }
//             
//             // 로딩 인디케이터
//             if viewModel.state.isLoading {
//                 loadingView
//             }
//         }
//         .onAppear {
//             viewModel.send(.viewDidLoad)
//             // 첫 화면 로드 시 금액 입력 필드에 포커스
//             DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                 isAmountFieldFocused = true
//             }
//         }
//         .onChange(of: viewModel.state.receiverAccount) { _ in
//             // 계좌 선택 후 금액 입력 필드에 포커스
//             isAmountFieldFocused = true
//         }
//         .sheet(isPresented: $viewModel.state.showAccountSelector) {
//             AccountSelectorView(
//                 accounts: viewModel.state.recentAccounts,
//                 onAccountSelected: { account in
//                     viewModel.send(.receiverSelected(account))
//                 }
//             )
//         }
//         .alert(item: errorBinding) { error in
//             Alert(
//                 title: Text("오류"),
//                 message: Text(error.localizedDescription),
//                 dismissButton: .default(Text("확인"))
//             )
//         }
//     }
//     
//     // MARK: - 컴포넌트
//     private var navigationBar: some View {
//         HStack {
//             Button(action: {
//                 viewModel.send(.backButtonTapped)
//                 presentationMode.wrappedValue.dismiss()
//             }) {
//                 Image(systemName: "chevron.left")
//                     .font(.title3)
//                     .foregroundColor(ColorTokens.Text.primary)
//             }
//             
//             Spacer()
//             
//             Text("송금")
//                 .font(typography.title3)
//                 .foregroundColor(ColorTokens.Text.primary)
//             
//             Spacer()
//             
//             Button(action: {
//                 viewModel.send(.closeButtonTapped)
//                 presentationMode.wrappedValue.dismiss()
//             }) {
//                 Image(systemName: "xmark")
//                     .font(.title3)
//                     .foregroundColor(ColorTokens.Text.primary)
//             }
//         }
//         .padding(.horizontal, 20)
//         .padding(.vertical, 12)
//         .background(ColorTokens.Background.primary)
//     }
//     
//     private var amountInputSection: some View {
//         VStack {
//             VStack(spacing: 16) {
//                 Text("얼마를 보낼까요?")
//                     .font(typography.title3)
//                     .foregroundColor(ColorTokens.Text.primary)
//                     .frame(maxWidth: .infinity, alignment: .leading)
//                 
//                 HStack(alignment: .center) {
//                     Text("₩")
//                         .font(typography.title1)
//                         .foregroundColor(ColorTokens.Text.primary)
//                     
//                     TextField("0", text: Binding(
//                         get: { viewModel.state.formattedAmount },
//                         set: { viewModel.send(.amountChanged($0)) }
//                     ))
//                     .font(typography.largeTitle)
//                     .keyboardType(.numberPad)
//                     .multilineTextAlignment(.trailing)
//                     .focused($isAmountFieldFocused)
//                 }
//                 .padding(.vertical, 8)
//                 
//                 Divider()
//                     .background(ColorTokens.Border.divider)
//                     .padding(.bottom, 8)
//                 
//                 // 잔액 및 오류 표시
//                 HStack {
//                     if let errorMessage = viewModel.state.amountError {
//                         Text(errorMessage)
//                             .font(typography.caption1)
//                             .foregroundColor(ColorTokens.State.error)
//                     } else {
//                         Text("잔액: \(viewModel.state.formattedBalance)")
//                             .font(typography.caption1)
//                             .foregroundColor(ColorTokens.Text.secondary)
//                     }
//                     
//                     Spacer()
//                     
//                     Button("전액") {
//                         viewModel.send(.maxAmountTapped)
//                     }
//                     .font(typography.caption1)
//                     .foregroundColor(ColorTokens.Brand.primary)
//                 }
//             }
//             .padding(16)
//         }
//         .background(ColorTokens.Background.card)
//         .cornerRadius(12)
//     }
//     
//     private var receiverSection: some View {
//         VStack(spacing: 12) {
//             Text("어디로 보낼까요?")
//                 .font(typography.title3)
//                 .foregroundColor(ColorTokens.Text.primary)
//                 .frame(maxWidth: .infinity, alignment: .leading)
//             
//             if let account = viewModel.state.receiverAccount {
//                 // 선택된 계좌 표시
//                 receiverAccountCard(account)
//             } else {
//                 // 계좌 선택 버튼
//                 Button(action: {
//                     viewModel.send(.selectReceiverTapped)
//                 }) {
//                     HStack {
//                         Image(systemName: "person.crop.circle")
//                             .font(.title2)
//                             .foregroundColor(ColorTokens.Brand.primary)
//                         
//                         Text("받을 계좌 선택하기")
//                             .font(typography.body)
//                             .foregroundColor(ColorTokens.Text.primary)
//                         
//                         Spacer()
//                         
//                         Image(systemName: "chevron.right")
//                             .font(.subheadline)
//                             .foregroundColor(ColorTokens.Text.secondary)
//                     }
//                     .padding(16)
//                     .background(ColorTokens.Background.secondary)
//                     .cornerRadius(12)
//                 }
//             }
//         }
//     }
//     
//     private func receiverAccountCard(_ account: FrequentAccount) -> some View {
//         VStack {
//             HStack {
//                 VStack(alignment: .leading, spacing: 4) {
//                     Text(account.bankName)
//                         .font(typography.bodyMedium)
//                         .foregroundColor(ColorTokens.Text.primary)
//                     
//                     Text(formatAccountNumber(account.accountNumber))
//                         .font(typography.caption)
//                         .foregroundColor(ColorTokens.Text.secondary)
//                     
//                     if let nickname = account.nickname {
//                         Text(nickname)
//                             .font(typography.captionSmall)
//                             .foregroundColor(ColorTokens.Text.tertiary)
//                     }
//                 }
//                 
//                 Spacer()
//                 
//                 Text(account.holderName)
//                     .font(typography.bodyMedium)
//                     .foregroundColor(ColorTokens.Text.secondary)
//                 
//                 Image(systemName: "chevron.right")
//                     .font(.subheadline)
//                     .foregroundColor(ColorTokens.Text.secondary)
//             }
//             .padding(16)
//             .contentShape(Rectangle())
//             .onTapGesture {
//                 viewModel.send(.selectReceiverTapped)
//             }
//         }
//     }
//     
//     private var memoSection: some View {
//         VStack(spacing: 8) {
//             Text("받는 분에게 표시될 메모")
//                 .font(typography.bodyMedium)
//                 .foregroundColor(ColorTokens.Text.primary)
//                 .frame(maxWidth: .infinity, alignment: .leading)
//             
//             TextField("(선택) 최대 20자", text: Binding(
//                 get: { viewModel.state.memo },
//                 set: { viewModel.send(.memoChanged(String($0.prefix(20)))) }
//             ))
//             .font(typography.body)
//             .padding(16)
//             .background(ColorTokens.Background.secondary)
//             .cornerRadius(12)
//         }
//     }
//     
//     private var continueButton: some View {
//         TossButton(
//             style: viewModel.state.isNextButtonEnabled ? .primary : .disabled,
//             action: {
//                 viewModel.send(.continueButtonTapped)
//             }
//         ) {
//             Text("다음")
//                 .frame(maxWidth: .infinity)
//                 .font(typography.button)
//         }
//         .frame(maxWidth: .infinity)
//         .padding(.horizontal, 20)
//         .padding(.vertical, 12)
//     }
//     
//     private var loadingView: some View {
//         ZStack {
//             Color.black.opacity(0.4).ignoresSafeArea()
//             
//             ProgressView()
//                 .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                 .scaleEffect(1.5)
//         }
//     }
//     
//     // 에러 바인딩
//     private var errorBinding: Binding<DomainError?> {
//         Binding<DomainError?>(
//             get: { viewModel.state.error },
//             set: { viewModel.state.error = $0 }
//         )
//     }
//     
//     // MARK: - 헬퍼 메서드
//     private func formatAccountNumber(_ number: String) -> String {
//         // 계좌번호 포맷팅 (예: 1234-56-7890123)
//         var formatted = number
//         
//         if number.count > 6 {
//             let index4 = number.index(number.startIndex, offsetBy: 4)
//             let index6 = number.index(number.startIndex, offsetBy: 6)
//             
//             formatted.insert("-", at: index4)
//             formatted.insert("-", at: index6)
//         }
//         
//         return formatted
//     }
// }
// 
// /// 계좌 선택 화면
// struct AccountSelectorView: View {
//     // MARK: - 속성
//     let accounts: [FrequentAccount]
//     let onAccountSelected: (FrequentAccount) -> Void
//     
//     @Environment(\.dismiss) private var dismiss
//     
//     // MARK: - 바디
//     var body: some View {
//         VStack(spacing: 0) {
//             // 헤더
//             HStack {
//                 Text("계좌 선택")
//                     .font(typography.title3)
//                     .fontWeight(.bold)
//                 
//                 Spacer()
//                 
//                 Button(action: {
//                     dismiss()
//                 }) {
//                     Image(systemName: "xmark")
//                         .font(.title3)
//                 }
//             }
//             .padding(.horizontal, 20)
//             .padding(.top, 20)
//             .padding(.bottom, 12)
//             
//             // 계좌 목록
//             if accounts.isEmpty {
//                 emptyAccountsView
//             } else {
//                 accountListView
//             }
//         }
//         .background(ColorTokens.Background.primary)
//     }
//     
//     private var accountListView: some View {
//         ScrollView {
//             LazyVStack(spacing: 12) {
//                 ForEach(accounts) { account in
//                     AccountRow(account: account)
//                         .onTapGesture {
//                             onAccountSelected(account)
//                         }
//                 }
//             }
//             .padding(.horizontal, 20)
//             .padding(.vertical, 8)
//         }
//     }
//     
//     private var emptyAccountsView: some View {
//         VStack(spacing: 16) {
//             Spacer()
//             
//             Image(systemName: "person.crop.circle.badge.questionmark")
//                 .font(.system(size: 50))
//                 .foregroundColor(ColorTokens.Text.secondary)
//             
//             Text("자주 쓰는 계좌가 없습니다")
//                 .font(typography.bodyMedium)
//                 .foregroundColor(ColorTokens.Text.primary)
//             
//             Text("계좌번호를 직접 입력해주세요")
//                 .font(typography.caption)
//                 .foregroundColor(ColorTokens.Text.secondary)
//             
//             Spacer()
//         }
//         .frame(maxWidth: .infinity)
//         .padding(.horizontal, 20)
//     }
// }
// 
// /// 계좌 목록 행
// struct AccountRow: View {
//     // MARK: - 속성
//     let account: FrequentAccount
//     
//     // MARK: - 바디
//     var body: some View {
//         VStack {
//             HStack {
//                 VStack(alignment: .leading, spacing: 4) {
//                     Text(account.bankName)
//                         .font(typography.bodyMedium)
//                         .foregroundColor(ColorTokens.Text.primary)
//                     
//                     HStack {
//                         Text(formatAccountNumber(account.accountNumber))
//                             .font(typography.caption)
//                             .foregroundColor(ColorTokens.Text.secondary)
//                         
//                         if let nickname = account.nickname {
//                             Text(nickname)
//                                 .font(typography.captionSmall)
//                                 .foregroundColor(ColorTokens.Text.secondary)
//                                 .padding(.horizontal, 6)
//                                 .padding(.vertical, 2)
//                                 .background(ColorTokens.Background.tertiary)
//                                 .cornerRadius(4)
//                         }
//                     }
//                 }
//                 
//                 Spacer()
//                 
//                 Text(account.holderName)
//                     .font(typography.bodyMedium)
//                     .foregroundColor(ColorTokens.Text.secondary)
//                 }
//             .padding(16)
//         }
//     }
//     
//     private func formatAccountNumber(_ number: String) -> String {
//         var formatted = number
//         
//         if number.count > 6 {
//             let index4 = number.index(number.startIndex, offsetBy: 4)
//             let index6 = number.index(number.startIndex, offsetBy: 6)
//             
//             formatted.insert("-", at: index4)
//             formatted.insert("-", at: index6)
//         }
//         
//         return formatted
//     }
// } 
