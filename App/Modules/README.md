# TossBankClone 모듈 구조

## 모듈 변경사항

기존 TossBankKit 모듈은 여러 책임을 가지고 있었습니다. Clean Architecture 원칙에 따라 다음과 같이 모듈을 재구성했습니다:

1. **TossBankKit**(제거됨) → 다음 모듈들로 분리:
   - DomainModule: 도메인 모델, 리포지토리 인터페이스, 유스케이스
   - DataModule: 리포지토리 구현체, 데이터 관련 로직
   - AuthenticationModule: 인증 관련 로직
   - CoordinatorModule: 네비게이션 관련 기본 프로토콜

2. **Feature 모듈** - 각 기능별 구현:
   - AuthFeature: 인증 관련 화면 및 기능
   - AccountFeature: 계좌 관련 화면 및 기능
   - SettingsFeature: 설정 관련 화면 및 기능

## 모듈 구성

프로젝트는 Clean Architecture를 따르는 다음 모듈들로 구성되어 있습니다:

### 1. 코어 모듈

- **DomainModule**: 도메인 모델, 리포지토리 인터페이스, 유스케이스 등 비즈니스 로직
- **DataModule**: 데이터 소스, 리포지토리 구현, 데이터베이스 관리
- **NetworkModule**: API 클라이언트, 네트워크 통신 로직
- **AuthenticationModule**: 인증 관련 로직
- **CoordinatorModule**: 네비게이션 관련 프로토콜

### 2. 기능 모듈

- **AuthFeature**: 인증 관련 기능 (로그인, 회원가입 등)
- **AccountFeature**: 계좌 관련 기능 (계좌 목록, 계좌 상세 등)
- **SettingsFeature**: 설정 관련 기능

### 3. 공유 모듈

- **DesignSystem**: UI 컴포넌트, 디자인 자산

## 모듈 간 의존성

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
      ├── AuthFeature
      │    ├── DomainModule
      │    ├── AuthenticationModule
      │    └── CoordinatorModule
      ├── AccountFeature
      │    ├── DomainModule
      │    └── CoordinatorModule
      └── SettingsFeature
           ├── DomainModule
           └── CoordinatorModule
```

## 주요 컴포넌트

### DomainModule

- **Models**: 도메인 모델 (Account, Transaction 등)
- **Repositories**: 리포지토리 인터페이스
- **UseCases**: 비즈니스 로직을 담당하는 유스케이스

### DataModule

- **Repositories**: 리포지토리 구현체
- **DataSources**: 데이터 소스 (로컬/원격)
- **SwiftData**: SwiftData 관련 로직

### NetworkModule

- **APIClient**: 네트워크 요청 처리
- **Endpoint**: API 엔드포인트 정의
- **API**: 구체적인 API 서비스

### AuthenticationModule

- **Manager**: 인증 관리자

### CoordinatorModule

- **Protocol**: 코디네이터 인터페이스

## 각 기능 모듈 내부 구조

각 기능 모듈은 Clean Architecture의 계층 구조를 따릅니다:

```
Feature/
├── Presentation/
│   ├── Views/
│   ├── ViewModels/
│   └── Coordinators/
├── Domain/ (필요시 DomainModule 의존)
└── Data/ (필요시 DataModule 의존)
```

## 이전 파일 구조에서 이동된 파일들

1. TossBankKit/Sources/Model/AccountModels.swift → DomainModule/Sources/Models/AccountModels.swift
2. TossBankKit/Sources/Model/AccountRepository.swift → DomainModule/Sources/Repositories/AccountRepository.swift
3. TossBankKit/Sources/Model/AccountUseCase.swift → DomainModule/Sources/UseCases/AccountUseCase.swift
4. TossBankKit/Sources/Model/MockAccountRepository.swift → DataModule/Sources/Repositories/MockAccountRepository.swift
5. TossBankKit/Sources/SwiftData/SwiftDataMigration.swift → DataModule/Sources/SwiftData/SchemaManager.swift
6. TossBankKit/Sources/Model/AuthenticationManager.swift → AuthenticationModule/Sources/Manager/AuthenticationManager.swift
7. TossBankKit/Sources/Coordinator/Coordinator.swift → CoordinatorModule/Sources/Protocol/Coordinator.swift
8. TossBankKit/Sources/DI/AppDIContainer.swift → App/DIContainer.swift 