import ProjectDescription
let projectName = "TossBankClone"
let project = Project(
    name: projectName,
    organizationName: "TossBank",
    targets: [
        .target(
            name: "TossBankClone",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.TossBankClone",
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleShortVersionString": "1.0",
                    "CFBundleVersion": "1",
                    "UILaunchStoryboardName": "LaunchScreen",
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": [
                            "UIWindowSceneSessionRoleApplication": [
                                [
                                    "UISceneConfigurationName": "Default Configuration",
                                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                                ]
                            ]
                        ]
                    ]
                ]
            ),
            sources: ["TossBankClone/Sources/**"],
            resources: ["TossBankClone/Resources/**"],
            dependencies: [
                .target(name: "DomainModule"),
                .target(name: "DataModule"),
                .target(name: "NetworkModule"),
                .target(name: "AuthenticationModule"),
                .target(name: "CoordinatorModule"),
                .target(name: "DesignSystem"),
                .target(name: "SharedModule"),
                .target(name: "AuthFeature"),
                .target(name: "AccountFeature"),
                .target(name: "SettingsFeature")
            ]
        ),
        .target(
            name: "AuthFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "io.tuist.TossBankClone.authfeature",
            infoPlist: .default,
            sources: ["Modules/Features/Auth/Sources/**"],
            resources: ["Modules/Features/Auth/Resources/**"],
            dependencies: [
                .target(name: "DomainModule"),
                .target(name: "NetworkModule"),
                .target(name: "DesignSystem"),
                .target(name: "SharedModule"),
                .target(name: "AuthenticationModule"),
                .target(name: "CoordinatorModule")
            ]
        ),
        .target(
            name: "AccountFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "io.tuist.TossBankClone.accountfeature",
            infoPlist: .default,
            sources: ["Modules/Features/Account/Sources/**"],
            resources: ["Modules/Features/Account/Resources/**"],
            dependencies: [
                .target(name: "DomainModule"),
                .target(name: "NetworkModule"),
                .target(name: "DesignSystem"),
                .target(name: "SharedModule"),
                .target(name: "CoordinatorModule")
            ]
        ),
        .target(
            name: "SettingsFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "io.tuist.TossBankClone.settingsfeature",
            infoPlist: .default,
            sources: ["Modules/Features/Settings/Sources/**"],
            resources: ["Modules/Features/Settings/Resources/**"],
            dependencies: [
                .target(name: "DomainModule"),
                .target(name: "DesignSystem"),
                .target(name: "SharedModule"),
                .target(name: "CoordinatorModule")
            ]
        ),
        .target(
            name: "DomainModule",
            destinations: .iOS,
            product: .framework,
            bundleId: "io.tuist.TossBankClone.domain",
            infoPlist: .default,
            sources: ["Modules/DomainModule/Sources/**"]
        ),
        .target(
            name: "DataModule",
            destinations: .iOS,
            product: .framework,
            bundleId: "io.tuist.TossBankClone.data",
            infoPlist: .default,
            sources: ["Modules/DataModule/Sources/**"],
            dependencies: [
                .target(name: "DomainModule")
            ]
        ),
        .target(
            name: "AuthenticationModule",
            destinations: .iOS,
            product: .framework,
            bundleId: "io.tuist.TossBankClone.authentication",
            infoPlist: .default,
            sources: ["Modules/AuthenticationModule/Sources/**"],
            dependencies: [
                .target(name: "DomainModule")
            ]
        ),
        .target(
            name: "CoordinatorModule",
            destinations: .iOS,
            product: .framework,
            bundleId: "io.tuist.TossBankClone.coordinator",
            infoPlist: .default,
            sources: ["Modules/CoordinatorModule/Sources/**"]
        ),
        .target(
            name: "NetworkModule",
            destinations: .iOS,
            product: .framework,
            bundleId: "io.tuist.TossBankClone.network",
            infoPlist: .default,
            sources: ["Modules/NetworkModule/Sources/**"],
            dependencies: []
        ),
        .target(
            name: "NetworkModuleTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.TossBankClone.network.tests",
            infoPlist: .default,
            sources: ["Modules/NetworkModule/Tests/**"],
            dependencies: [
                .target(name: "NetworkModule")
            ]
        ),
        .target(
            name: "SharedModule",
            destinations: .iOS,
            product: .framework,
            bundleId: "io.tuist.TossBankClone.shared",
            infoPlist: .default,
            sources: ["Modules/SharedModule/Sources/**"],
            dependencies: []
        ),
        .target(
            name: "DesignSystem",
            destinations: .iOS,
            product: .framework,
            bundleId: "io.tuist.TossBankClone.designsystem",
            infoPlist: .default,
            sources: ["Modules/DesignSystem/Sources/**"],
            resources: ["Modules/DesignSystem/Resources/**"]
        ),
        .target(
            name: "TossBankCloneTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.TossBankClone.tests",
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "TossBankClone")
            ]
        )
    ]
)
