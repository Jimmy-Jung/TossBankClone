import XCTest
@testable import TossBankClone
@testable import NetworkModule
@testable import AccountFeature
@testable import DomainModule
@testable import DataModule
@testable import CoordinatorModule

class DIContainerTests: XCTestCase {
    
    // MARK: - 테스트 대상 및 모의 객체
    private var appDIContainer: AppDIContainer!
    private var mockNetworkService: MockNetworkService!
    
    // MARK: - 셋업 및 테어다운
    override func setUp() {
        super.setUp()
        
        // 테스트 환경에서 DIContainer 생성
        let baseURL = URL(string: "https://api.test.tossbank.com")!
        appDIContainer = AppDIContainer(environment: .test, baseURL: baseURL)
        
        // mockNetworkService 참조 가져오기
        mockNetworkService = appDIContainer.mockNetworkService
    }
    
    override func tearDown() {
        mockNetworkService = nil
        appDIContainer = nil
        
        super.tearDown()
    }
    
    // MARK: - 테스트 메서드
    func testEnvironmentSetup() {
        // 환경 설정 확인
        XCTAssertEqual(appDIContainer.environment, .test)
        XCTAssertNotNil(appDIContainer.mockNetworkService)
    }
    
    func testAuthDIContainer() {
        // AuthDIContainer 생성
        let authDIContainer = appDIContainer.authDIContainer()
        
        // AuthDIContainer 타입 확인
        XCTAssertTrue(authDIContainer is AuthDIContainer)
    }
    
    func testAccountDIContainer() {
        // AccountDIContainer 생성
        let accountDIContainer = appDIContainer.accountDIContainer()
        
        // AccountDIContainer 타입 확인
        XCTAssertTrue(accountDIContainer is AccountDIContainer)
        
        // 가짜 계좌 데이터 설정
        let mockAccount = TestAccount(id: "test1", name: "테스트 계좌", balance: 10000)
        mockNetworkService.setSuccessResponse(for: "/accounts/test1", data: mockAccount)
        
        // AccountDIContainer의 ViewModel 생성
        if let container = accountDIContainer as? AccountDIContainer {
            let viewModel = container.makeAccountDetailViewModel(accountId: "test1")
            
            // ViewModel 타입 확인
            XCTAssertTrue(viewModel is AccountDetailViewModel)
        } else {
            XCTFail("AccountDIContainer가 예상한 타입이 아닙니다")
        }
    }
    
    func testTransferDIContainer() {
        // TransferDIContainer 생성
        let transferDIContainer = appDIContainer.transferDIContainer()
        
        // TransferDIContainer 타입 확인
        XCTAssertTrue(transferDIContainer is TransferDIContainer)
    }
    
    func testSettingsDIContainer() {
        // SettingsDIContainer 생성
        let settingsDIContainer = appDIContainer.settingsDIContainer()
        
        // SettingsDIContainer 타입 확인
        XCTAssertTrue(settingsDIContainer is SettingsDIContainer)
    }
    
    func testMockNetworkResponses() {
        // 가짜 응답 설정
        let successData = TestResponse(success: true, message: "성공")
        mockNetworkService.setSuccessResponse(for: "/test", data: successData)
        
        // 에러 응답 설정
        mockNetworkService.setHTTPErrorResponse(for: "/error", statusCode: 404)
        
        // 네트워크 요청 실행 (실제 구현에서는 DIContainer를 통해 생성된 ViewModel에서 호출)
        // 이 테스트는 설정이 올바르게 되었는지만 확인
        XCTAssertNotNil(mockNetworkService.getCapturedRequests())
    }
}

// MARK: - 테스트용 모델
struct TestAccount: Codable {
    let id: String
    let name: String
    let balance: Int
}

struct TestResponse: Codable {
    let success: Bool
    let message: String
} 