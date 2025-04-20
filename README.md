# TossBankClone

토스뱅크 애플리케이션을 모방한 iOS 앱 프로젝트입니다. 클린 아키텍처와 모듈식 구조를 활용하여 개발되었습니다.

## 목차
- [프로젝트 개요](#프로젝트-개요)
- [프로젝트 구조](#프로젝트-구조)
- [주차별 개발 계획](#주차별-개발-계획)
- [주요 기능 및 구현 가이드](#주요-기능-및-구현-가이드)
- [기술 스택](#기술-스택)
- [아키텍처 및 디자인 패턴](#아키텍처-및-디자인-패턴)
- [디렉토리 구조](#디렉토리-구조)
- [개발 환경 설정](#개발-환경-설정)
- [코딩 컨벤션](#코딩-컨벤션)
- [오프라인 지원](#오프라인-지원)

## 프로젝트 개요

이 프로젝트는 토스뱅크의 핵심 기능(계좌 관리, 송금, 거래 내역)을 구현한 클론 앱입니다. 확장성과 유지보수성을 고려한 클린 아키텍처를 채택하여 모듈화된 구조로 개발되었습니다.

## 프로젝트 구조

프로젝트는 다음과 같은 모듈로 구성되어 있습니다:

### 핵심 모듈

- **DomainModule**: 비즈니스 로직의 핵심이 되는 모듈
  - `Models`: 도메인 모델 정의 (Account, Transaction 등)
  - `Repositories`: 리포지토리 인터페이스 정의
  - `UseCases`: 비즈니스 로직을 캡슐화한 UseCase 구현

- **DataModule**: 데이터 액세스 계층
  - `DTOs`: API 응답을 매핑하는 데이터 전송 객체
  - `APIRequests`: API 엔드포인트 정의
  - `Repositories`: 리포지토리 구현체
  - `SwiftData`: 로컬 데이터베이스 모델 및 관리
  - `DataSources`: 로컬/원격 데이터 소스 구현

- **NetworkModule**: 네트워크 통신 계층
  - `APIClient`: API 통신을 담당하는 클라이언트
  - `Interceptors`: 요청/응답 처리를 위한 인터셉터
  - `Errors`: 네트워크 오류 정의
  - `Reachability`: 네트워크 연결 상태 모니터링

- **AuthenticationModule**: 인증 관련 로직을 담당하는 모듈
  - `Manager`: 인증 관리자 (PIN 설정, 생체 인증 등)
  - `Services`: 토큰 관리, 키체인 접근 등의 서비스

### UI 및 기능 모듈

- **DesignSystem**: UI 컴포넌트 라이브러리
  - `Colors`: 색상 정의
  - `Typography`: 텍스트 스타일 정의
  - `Components`: 재사용 가능한 UI 컴포넌트

- **CoordinatorModule**: 화면 전환 및 네비게이션 관리
  - `Protocols`: 코디네이터 프로토콜 정의
  - `Extensions`: 코디네이터 확장 기능

- **Features**: 각 기능별 화면 구현
  - `Account`: 계좌 관련 기능
  - `Auth`: 인증 관련 기능
  - `Transfer`: 송금 관련 기능
  - `Settings`: 설정 관련 기능

## 주차별 개발 계획

### 1주차: 프로젝트 설정 및 기본 UI 구현
- 프로젝트 구조 설정 및 모듈화
- 디자인 시스템 구현 (색상, 타이포그래피, 기본 컴포넌트)
- 기본 네비게이션 구조 구현
- 로그인/회원가입 화면 UI 구현

**주요 파일:**
- `App/Project.swift`: Tuist 프로젝트 설정
- `App/Modules/DesignSystem/Sources/Colors`: 색상 정의
- `App/Modules/DesignSystem/Sources/Typography`: 타이포그래피 정의
- `App/Modules/DesignSystem/Sources/Components`: 공통 컴포넌트

### 2주차: 계좌 화면 및 데이터 모델 구현
- 도메인 모델 및 리포지토리 인터페이스 정의
- 계좌 목록 및 상세 화면 구현
- 거래 내역 화면 구현
- 계좌 관련 UseCase 구현

**주요 파일:**
- `App/Modules/DomainModule/Sources/Models/AccountModels.swift`: 계좌 도메인 모델
- `App/Modules/DomainModule/Sources/Repositories/AccountRepository.swift`: 계좌 리포지토리 인터페이스
- `App/Modules/DomainModule/Sources/UseCases/AccountUseCase.swift`: 계좌 관련 UseCase
- `App/Modules/Features/Account/Sources/Presentation/View`: 계좌 관련 화면

### 3주차: 인증 및 보안 기능 구현
- 로그인/회원가입 기능 구현
- 키체인을 활용한 토큰 관리
- 생체 인증 (FaceID/TouchID) 구현
- 보안 기능 구현 (화면 캡처 방지, 앱 전환 시 보안)

**주요 파일:**
- `App/Modules/DomainModule/Sources/Models/AuthModels.swift`: 인증 관련 도메인 모델
- `App/Modules/DomainModule/Sources/UseCases/AuthUseCase.swift`: 인증 관련 UseCase
- `App/Modules/DataModule/Sources/Repositories/AuthRepositoryImpl.swift`: 인증 리포지토리 구현
- `App/Modules/AuthenticationModule/Sources/Manager/AuthenticationManager.swift`: 인증 관리자
- `App/Modules/Features/Auth/Sources/Presentation/Views`: 인증 관련 화면
- `App/Modules/Features/Auth/Sources/Presentation/ViewModels`: 인증 화면 상태 관리

### 4주차: 네트워킹 및 송금 기능 구현
- 네트워크 레이어 구현 (API 클라이언트, 에러 처리)
- SwiftData를 활용한 로컬 데이터 저장소 구현
- 송금 기능 구현 (송금 화면, 확인 화면)
- 앱 내 알림 시스템 구현

**주요 파일:**
- `App/Modules/NetworkModule/Sources/APIClient.swift`: API 클라이언트 구현
- `App/Modules/DataModule/Sources/SwiftData`: SwiftData 모델 및 관리
- `App/Modules/DomainModule/Sources/Repositories/TransferRepository.swift`: 송금 리포지토리 인터페이스
- `App/Modules/DataModule/Sources/Repositories/TransferRepositoryImpl.swift`: 송금 리포지토리 구현
- `App/Modules/Features/Transfer/Sources/Presentation`: 송금 관련 화면

## 주요 기능 및 구현 가이드

### 계좌 관리 기능

계좌 정보는 도메인 레이어에서 `Account` 모델로 정의되며, `AccountRepository`를 통해 접근합니다. SwiftData를 사용하여 로컬에 저장되며, 온라인 상태일 때 서버와 동기화됩니다.

**핵심 클래스 역할:**
- `Account`: 계좌 도메인 모델
- `AccountRepositoryProtocol`: 계좌 데이터 접근 인터페이스
- `AccountRepositoryImpl`: 계좌 리포지토리 구현체
- `FetchAccountsUseCase`: 계좌 목록 조회 비즈니스 로직
- `AccountViewModel`: 계좌 화면 상태 관리

**새 기능 추가 방법:**
1. 도메인 모델 및 리포지토리 인터페이스 정의 (DomainModule)
2. UseCase 구현 (DomainModule)
3. 리포지토리 구현체 작성 (DataModule)
4. ViewModel 및 View 구현 (Features/Account)

```swift
// 계좌 정보 조회 예시
let accountsUseCase = FetchAccountsUseCase(accountRepository: accountRepository)
let result = await accountsUseCase.execute()

switch result {
case .success(let accounts):
    // 계좌 목록 표시
case .failure(let error):
    // 오류 처리
}
```

### 인증 기능

PIN 번호 설정 및 로그인, 생체 인증(Face ID/Touch ID) 등 인증 관련 기능을 구현합니다.

**핵심 클래스 역할:**
- `AuthenticationManager`: 인증 관련 로직 관리
- `PINSetupViewModel`: PIN 설정 화면 상태 관리
- `PINLoginViewModel`: PIN 로그인 화면 상태 관리
- `PINSetupView`: PIN 설정 UI 구현
- `PINLoginView`: PIN 로그인 UI 구현

**인증 프로세스:**
1. 앱 최초 실행 시 PIN 설정 요청
2. PIN 설정 후 생체 인증 등록 가능
3. 이후 실행 시 PIN 또는 생체 인증으로 로그인
4. 인증 실패 시 제한된 횟수 이상 시도 시 계정 잠금

```swift
// PIN 로그인 예시
let viewModel = PINLoginViewModel()

// PIN 번호 입력 처리
func onNumberTapped(_ number: Int) {
    viewModel.onNumberTapped(number)
}

// 생체 인증 요청
func authenticateWithBiometrics() {
    viewModel.authenticateWithBiometrics()
}
```

### 송금 기능

송금 기능은 `TransferRepository`를 통해 구현되며, 송금 전 계좌 잔액 확인 및 송금 한도 검증이 이루어집니다. 송금 후 거래 내역에 자동으로 추가됩니다.

**핵심 클래스 역할:**
- `TransferRepositoryProtocol`: 송금 관련 데이터 접근 인터페이스
- `TransferRepositoryImpl`: 송금 리포지토리 구현체
- `TransferFundsUseCase`: 송금 처리 비즈니스 로직
- `TransferViewModel`: 송금 화면 상태 관리
- `TransferView`: 송금 UI 구현

**송금 프로세스:**
1. 송금액 및 수신 계좌 입력 (TransferView)
2. 송금 가능 여부 검증 (TransferViewModel)
3. 송금 실행 (TransferFundsUseCase)
4. 결과 처리 및 피드백 제공 (TransferView)

```swift
// 송금 실행 예시
let transferUseCase = TransferFundsUseCase(
    transferRepository: transferRepository,
    accountRepository: accountRepository
)

let result = await transferUseCase.execute(
    fromAccountId: sourceAccountId,
    toAccountNumber: receiverAccountNumber,
    amount: amount,
    description: memo
)

switch result {
case .success(let transferResult):
    // 송금 성공 처리
case .failure(let error):
    // 오류 처리
}
```

### SwiftData 모델 및 로컬 저장소

SwiftData를 사용하여 로컬 데이터를 저장하고 관리합니다. 엔티티는 `@Model` 어노테이션으로 정의되며, `SchemaManager`를 통해 스키마를 관리합니다.

**핵심 클래스 역할:**
- `Account`, `Transaction`, `TransferEntity`: SwiftData 모델
- `SchemaManager`: SwiftData 스키마 관리
- `AccountRepositoryImpl`, `TransferRepositoryImpl`: SwiftData를 사용한 리포지토리 구현

**SwiftData 모델 정의 및 사용 방법:**
```swift
// 모델 정의
@Model
public final class AccountEntity {
    @Attribute(.unique) public var id: String
    public var name: String
    public var type: AccountType
    public var balance: Decimal
    // ...
}

// 모델 컨테이너 생성
let container = try SchemaManager.createModelContainer()
let context = ModelContext(container)

// 데이터 조회
let descriptor = FetchDescriptor<Account>()
let accounts = try context.fetch(descriptor)
```

## 기술 스택

- **언어**: Swift 5.9+
- **UI 프레임워크**: SwiftUI, UIKit(일부 화면)
- **아키텍처**: MVVM + Clean Architecture
- **네비게이션**: Coordinator 패턴
- **로컬 데이터베이스**: SwiftData
- **의존성 관리**: Tuist
- **네트워킹**: URLSession + 자체 구현 API 클라이언트
- **비동기 처리**: Swift Concurrency(async/await)
- **반응형 프로그래밍**: Combine
- **보안**: KeyChain, LocalAuthentication

## 아키텍처 및 디자인 패턴

### Clean Architecture

프로젝트는 Clean Architecture 원칙을 따라 다음과 같은 레이어로 구성됩니다:

1. **Presentation Layer (Features)**
   - View: SwiftUI 뷰
   - ViewModel: 화면 상태 관리 및 사용자 액션 처리
   - Coordinator: 화면 전환 및 네비게이션 관리
   - Controller: UIKit 컨트롤러(일부 화면)

2. **Domain Layer (DomainModule)**
   - UseCase: 비즈니스 로직 캡슐화
   - Repository Interfaces: 데이터 액세스 추상화
   - Domain Models: 비즈니스 모델

3. **Data Layer (DataModule)**
   - Repository Implementations: 리포지토리 구현체
   - Data Sources: 로컬/원격 데이터 소스
   - DTOs: 데이터 전송 객체

![Clean Architecture](https://blog.cleancoder.com/uncle-bob/images/2012-08-13-the-clean-architecture/CleanArchitecture.jpg)

### MVVM 패턴

각 화면은 MVVM(Model-View-ViewModel) 패턴을 따릅니다:

- **Model**: 도메인 모델 및 비즈니스 로직
- **View**: UI 표현 (SwiftUI)
- **ViewModel**: View와 Model 사이의 중재자

```swift
// ViewModel 예시
public final class AccountListViewModel: ObservableObject {
    @Published private(set) var state: AccountListState
    private let fetchAccountsUseCase: FetchAccountsUseCaseProtocol
    
    public func send(_ action: AccountListAction) {
        switch action {
        case .viewDidLoad:
            loadAccounts()
        // ...
        }
    }
    
    private func loadAccounts() {
        state.isLoading = true
        Task { @MainActor in
            let result = await fetchAccountsUseCase.execute()
            state.isLoading = false
            
            switch result {
            case .success(let accounts):
                state.accounts = accounts
            case .failure(let error):
                state.error = error
            }
        }
    }
}
```

### Coordinator 패턴

화면 전환 및 네비게이션은 Coordinator 패턴을 통해 관리됩니다:

```swift
public final class AccountCoordinator: ObservableObject, Coordinator {
    public enum Route {
        case accountList
        case accountDetail(accountId: String)
        case transactions(accountId: String)
    }
    
    @Published public var path = NavigationPath()
    
    public func build(route: Route) -> some View {
        switch route {
        case .accountList:
            makeAccountListView()
        case .accountDetail(let accountId):
            makeAccountDetailView(accountId: accountId)
        case .transactions(let accountId):
            makeTransactionsView(accountId: accountId)
        }
    }
    
    public func navigate(to route: Route) {
        path.append(route)
    }
    
    // ...
}
```

### 모듈 간 의존성

```
App
 ├── DomainModule
 ├── DataModule
 │    └── DomainModule
 ├── NetworkModule
 ├── AuthenticationModule
 │    └── DomainModule
 ├── CoordinatorModule
 └── Features
      ├── Auth
      │    ├── DomainModule
      │    ├── AuthenticationModule
      │    └── CoordinatorModule
      ├── Account
      │    ├── DomainModule
      │    └── CoordinatorModule
      ├── Transfer
      │    ├── DomainModule
      │    └── CoordinatorModule
      └── Settings
           ├── DomainModule
           └── CoordinatorModule
```

## 디렉토리 구조

```
App/
├── Project.swift                # Tuist 프로젝트 설정
├── TossBankClone/               # 앱 메인 타겟
├── Modules/                     # 모듈 디렉토리
│   ├── DomainModule/            # 도메인 레이어
│   │   └── Sources/
│   │       ├── Models/          # 도메인 모델
│   │       ├── Repositories/    # 리포지토리 인터페이스
│   │       └── UseCases/        # 비즈니스 로직
│   ├── DataModule/              # 데이터 레이어
│   │   └── Sources/
│   │       ├── APIRequests/     # API 요청 정의
│   │       ├── DTOs/            # 데이터 전송 객체
│   │       ├── Repositories/    # 리포지토리 구현
│   │       └── SwiftData/       # 로컬 데이터베이스
│   ├── NetworkModule/           # 네트워크 레이어
│   │   └── Sources/
│   │       ├── APIClient/       # API 클라이언트
│   │       ├── Interceptors/    # 요청/응답 인터셉터
│   │       └── Errors/          # 네트워크 오류 정의
│   ├── AuthenticationModule/    # 인증 관련 모듈
│   │   └── Sources/
│   │       └── Manager/         # 인증 관리자
│   ├── DesignSystem/            # UI 디자인 시스템
│   │   └── Sources/
│   │       ├── Colors/          # 색상 정의
│   │       ├── Typography/      # 타이포그래피 정의
│   │       └── Components/      # UI 컴포넌트
│   ├── CoordinatorModule/       # 네비게이션 관리
│   │   └── Sources/
│   │       └── Protocols/       # 코디네이터 프로토콜
│   └── Features/                # 기능별 모듈
│       ├── Account/             # 계좌 관련 기능
│       │   └── Sources/
│       │       └── Presentation/
│       │           └── Coordinators/ # 화면 전환
│       ├── Auth/                # 인증 관련 기능
│       │   └── Sources/
│       │       └── Presentation/
│       │           ├── Views/    # 화면 구현
│       │           ├── ViewModels/ # 화면 상태 관리
│       │           ├── Controller/ # UIKit 컨트롤러
│       │           └── Coordinators/ # 화면 전환
│       ├── Transfer/            # 송금 관련 기능
│       └── Settings/            # 설정 관련 기능
└── Tests/                       # 테스트 디렉토리
```

## 개발 환경 설정

### 요구사항
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Tuist

### 설치 방법

1. 저장소 클론
```bash
git clone https://github.com/yourusername/TossBankClone.git
cd TossBankClone
```

2. Tuist 설치 (없는 경우)
```bash
curl -Ls https://install.tuist.io | bash
```

3. Tuist를 사용하여 프로젝트 생성
```bash
tuist generate
```

4. Xcode에서 프로젝트 열기
```bash
open App/TossBankClone.xcworkspace
```

## 코딩 컨벤션

### 네이밍 규칙
- 클래스, 구조체, 열거형: UpperCamelCase (예: `AccountListView`)
- 변수, 함수: lowerCamelCase (예: `fetchAccounts()`)
- 프로토콜: 접미사 `Protocol` 또는 기능 설명 (예: `AccountRepositoryProtocol`)
- 파일명: 포함된 주요 타입과 동일한 이름 사용

### 아키텍처 규칙
- 각 레이어는 자신보다 안쪽 레이어에만 의존성을 가짐
- 리포지토리는 항상 프로토콜로 추상화하여 의존성 역전
- ViewModel은 UseCase를 통해서만 데이터에 접근
- UI 로직과 비즈니스 로직 분리

### 기능 추가 절차
1. 도메인 모델 및 리포지토리 인터페이스 정의
2. UseCase 구현 (비즈니스 로직)
3. 리포지토리 구현체 작성
4. ViewModel 구현 (화면 상태 관리)
5. View 구현 (UI)
6. 코디네이터에 새 화면 추가

## 오프라인 지원

앱은 오프라인 모드를 지원합니다:

### 오프라인 처리 메커니즘
- `NetworkReachability`를 통한 네트워크 연결 상태 모니터링
- 오프라인 상태에서는 로컬 데이터 사용
- 온라인 상태로 전환 시 데이터 동기화

### 데이터 동기화 전략
- 온라인 상태에서 API 호출 후 로컬 데이터 업데이트
- 오프라인 상태에서 수행된 작업을 큐에 저장
- 네트워크 복구 시 큐에 저장된 작업 실행

### 구현 예시
```swift
public func fetchAccounts() async throws -> [Account] {
    // 온라인 상태이면 API에서 데이터 가져오기
    if connectivityChecker.isConnected && apiClient != nil {
        do {
            let onlineAccounts = try await fetchOnlineAccounts()
            await updateLocalAccounts(with: onlineAccounts)
            return onlineAccounts
        } catch {
            // API 요청 실패 시 로컬 데이터 반환
            print("온라인 계좌 조회 실패: \(error.localizedDescription)")
        }
    }
    
    // 오프라인이거나 API 요청 실패 시 로컬 데이터 반환
    return try await fetchLocalAccounts()
}
```
