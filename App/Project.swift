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
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .target(name: "TossBankKit"),
                .target(name: "DesignSystem"),
                .target(name: "NetworkModule")
            ]
        ),
        .target(
            name: "TossBankKit",
            destinations: .iOS,
            product: .framework,
            bundleId: "io.tuist.TossBankClone.kit",
            infoPlist: .default,
            sources: ["Modules/TossBankKit/Sources/**"],
            dependencies: [
                .target(name: "NetworkModule"),
                .target(name: "DesignSystem")
            ]
        ),
        .target(
            name: "NetworkModule",
            destinations: .iOS,
            product: .framework,
            bundleId: "io.tuist.TossBankClone.network",
            infoPlist: .default,
            sources: ["Modules/NetworkModule/Sources/**"]
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
