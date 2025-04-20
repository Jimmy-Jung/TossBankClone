import UIKit
import SwiftUI
import TossBankKit
import DesignSystem

public class AuthViewController: UIViewController {
    // MARK: - 속성
    private weak var coordinator: AuthCoordinator?
    private let authManager = AuthenticationManager.shared
    
    // MARK: - 생성자
    public init(coordinator: AuthCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 라이프사이클
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundPrimary
        setupInitialScreen()
    }
    
    // MARK: - 화면 설정
    private func setupInitialScreen() {
        // PIN이 설정되어 있는지 확인
        if authManager.isPINSet() {
            // PIN 설정되어 있으면 로그인 화면
            showPINLoginView()
        } else {
            // PIN 설정되어 있지 않으면 설정 화면
            showPINSetupView()
        }
    }
    
    // MARK: - 화면 전환 메서드
    private func showPINLoginView() {
        let pinLoginView = PINLoginView { [weak self] in
            // 로그인 성공 시 메인 화면으로 이동
            // self?.coordinator?.didFinishAuthentication()
        }
        
        let hostingController = UIHostingController(rootView: pinLoginView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
    
    private func showPINSetupView() {
        let pinSetupView = PINSetupView { [weak self] in
            // PIN 설정 완료 시 로그인 화면으로 전환
            // self?.coordinator?.didFinishAuthentication()
        }
        
        let hostingController = UIHostingController(rootView: pinSetupView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
} 
