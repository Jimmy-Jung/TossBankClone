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
                .target(name: "DesignSystem"),
                .target(name: "SharedModule"),
                .target(name: "AuthFeature"),
                .target(name: "AccountFeature"),
                .target(name: "SettingsFeature"),
                .target(name: "TransferFeature"),
                .target(name: "AuthenticationModule")
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
                .target(name: "DataModule"),
                .target(name: "NetworkModule"),
                .target(name: "DesignSystem"),
                .target(name: "SharedModule"),
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
                .target(name: "DataModule"),
                .target(name: "NetworkModule"),
                .target(name: "DesignSystem"),
                .target(name: "SharedModule"),
            ]
        ),
        .target(
            name: "TransferFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "io.tuist.TossBankClone.transferfeature",
            infoPlist: .default,
            sources: ["Modules/Features/Transfer/Sources/**"],
            resources: ["Modules/Features/Transfer/Resources/**"],
            dependencies: [
                .target(name: "DomainModule"),
                .target(name: "DataModule"),
                .target(name: "NetworkModule"),
                .target(name: "DesignSystem"),
                .target(name: "SharedModule"),
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
                .target(name: "DataModule"),
                .target(name: "NetworkModule"),
                .target(name: "DesignSystem"),
                .target(name: "SharedModule"),
            ]
        ),
        .target(
            name: "DomainModule",
            destinations: .iOS,
            product: .framework,
            bundleId: "io.tuist.TossBankClone.domain",
            infoPlist: .default,
            sources: ["Modules/Cores/DomainModule/Sources/**"],
            dependencies: [
                .target(name: "AuthenticationModule")
            ]
        ),
        .target(
            name: "DataModule",
            destinations: .iOS,
            product: .framework,
            bundleId: "io.tuist.TossBankClone.data",
            infoPlist: .default,
            sources: ["Modules/Cores/DataModule/Sources/**"],
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
            sources: ["Modules/Cores/AuthenticationModule/Sources/**"],
            dependencies: [
            ]
        ),
        .target(
            name: "NetworkModule",
            destinations: .iOS,
            product: .framework,
            bundleId: "io.tuist.TossBankClone.network",
            infoPlist: .default,
            sources: ["Modules/Cores/NetworkModule/Sources/**"],
            dependencies: []
        ),
        .target(
            name: "NetworkModuleTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.TossBankClone.network.tests",
            infoPlist: .default,
            sources: ["Modules/Cores/NetworkModule/Tests/**"],
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
            sources: ["Modules/Cores/SharedModule/Sources/**"],
            dependencies: [
                .target(name: "DomainModule"),
                
            ]
        ),
        .target(
            name: "DesignSystem",
            destinations: .iOS,
            product: .framework,
            bundleId: "io.tuist.TossBankClone.designsystem",
            infoPlist: .default,
            sources: ["Modules/Cores/DesignSystem/Sources/**"],
            resources: ["Modules/Cores/DesignSystem/Resources/**"]
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
