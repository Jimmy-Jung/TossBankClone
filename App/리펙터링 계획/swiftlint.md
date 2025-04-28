
# SwiftLint 적용 가이드 - 토스뱅크 클론 프로젝트

## 1. SwiftLint 설치

```bash
# Homebrew를 통한 설치
brew install swiftlint

# 또는 CocoaPods를 통한 설치 (프로젝트별)
pod 'SwiftLint'
```

## 2. 기본 설정 파일 생성

프로젝트 루트 디렉토리에 `.swiftlint.yml` 파일 생성:

```bash
cd /Users/zundaeng/Documents/GitHub/TossBankClone
touch .swiftlint.yml
```

## 3. SwiftLint 설정 구성

`.swiftlint.yml` 파일에 다음 내용 추가:

```yaml
# 포함할 디렉토리 경로
included:
  - App
  - App/Modules
  - App/TossBankClone

# 제외할 디렉토리/파일
excluded:
  - Pods
  - App/Derived
  - Tuist
  - "**/*.generated.swift"
  - "**/*Tests"

# 비활성화할 규칙
disabled_rules:
  - trailing_whitespace
  - todo
  - multiple_closures_with_trailing_closure

# 기본값에서 사용자 정의로 변경할 규칙
opt_in_rules:
  - empty_count
  - empty_string
  - closure_spacing
  - conditional_returns_on_newline
  - contains_over_first_not_nil
  - fatal_error_message
  - force_unwrapping
  - implicitly_unwrapped_optional
  - multiline_parameters
  - operator_usage_whitespace
  - overridden_super_call
  - private_outlet
  - prohibited_super_call
  - redundant_nil_coalescing
  - sorted_imports

# 라인 길이 제한
line_length:
  warning: 120
  error: 150
  ignores_comments: true
  ignores_urls: true

# 타입 바디 길이 제한
type_body_length:
  warning: 300
  error: 500

# 파일 길이 제한
file_length:
  warning: 500
  error: 1000

# 함수 바디 길이 제한
function_body_length:
  warning: 50
  error: 100

# 중첩 제한
nesting:
  type_level:
    warning: 3
  statement_level:
    warning: 5

# 경고 수준으로 설정할 규칙
warning_threshold: 15
```

## 4. Tuist 프로젝트에 SwiftLint 통합

Tuist 프로젝트에서는 각 모듈 프로젝트에 SwiftLint를 적용해야 합니다:

```swift
// App/Project.swift 및 각 모듈의 Project.swift 파일 수정

import ProjectDescription

let project = Project(
    // 기존 설정...
    
    settings: .settings(
        base: [
            "SWIFT_TREAT_WARNINGS_AS_ERRORS": "YES",
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release")
        ],
        defaultSettings: .recommended
    ),
    
    targets: [
        Target(
            name: "ModuleName",
            // 기존 설정...
            scripts: [
                .post(
                    script: """
                    if which swiftlint >/dev/null; then
                      swiftlint
                    else
                      echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
                    fi
                    """,
                    name: "SwiftLint"
                )
            ]
        )
    ]
)
```

## 5. Xcode Build Phase에 SwiftLint 추가 (Tuist 사용하지 않을 경우)

1. 프로젝트 선택 > 타겟 선택 > Build Phases 탭 선택
2. "+" 버튼 클릭 > "New Run Script Phase" 선택
3. 다음 스크립트 추가:

```bash
if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
```

## 6. 모듈별 맞춤 설정 (선택 사항)

각 모듈별로 특정 규칙을 다르게 적용하고 싶다면 모듈 디렉토리에 개별 `.swiftlint.yml` 파일을 생성할 수 있습니다:

```bash
# 예: NetworkModule에 맞춤 규칙 적용
cd /Users/zundaeng/Documents/GitHub/TossBankClone/App/Modules/NetworkModule
touch .swiftlint.yml
```

```yaml
# NetworkModule/.swiftlint.yml
# 부모 설정에서 상속받음
parent_config: ../../.swiftlint.yml

# 네트워크 모듈에서는 force_try를 허용 (예시)
disabled_rules:
  - force_try
```

## 7. 자동 수정 사용

코드를 자동으로 수정할 수 있는 규칙들에 대해 자동 수정을 적용:

```bash
cd /Users/zundaeng/Documents/GitHub/TossBankClone
swiftlint autocorrect
```

특정 디렉토리만 수정:

```bash
swiftlint autocorrect --path App/Modules/DomainModule
```

## 8. CI/CD 파이프라인 통합

GitHub Actions에 SwiftLint 검사 추가:

```yaml
# .github/workflows/swiftlint.yml
name: SwiftLint

on:
  pull_request:
    paths:
      - '**/*.swift'

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: GitHub Action for SwiftLint
        uses: norio-nomura/action-swiftlint@3.2.1
        with:
          args: --strict
```

## 9. Fastlane과 통합

```ruby
# fastlane/Fastfile
desc "Run SwiftLint"
lane :lint do
  swiftlint(
    mode: :lint,      # lint 또는 autocorrect
    strict: true,     # 위반 시 빌드 실패
    config_file: '.swiftlint.yml',
    reporter: 'json', # 결과 형식
    output_file: 'swiftlint-results.json'
  )
end

# 테스트 전에 린트 실행
lane :tests do
  lint
  # 기존 테스트 코드...
end
```

## 10. 팁과 베스트 프랙티스

### 점진적 적용

기존 코드베이스에 한번에 적용하기 어려울 경우:

```yaml
# .swiftlint.yml
analyzer_rules:
  - unused_declaration
  - unused_import

# 특정 파일이나 디렉토리는 제외
excluded:
  - App/Legacy
  - "**/*ViewModel.swift" # 기존 뷰모델은 일단 제외
```

### 특정 코드 라인 규칙 비활성화

```swift
// swiftlint:disable:next force_cast
let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomCell

// 여러 줄 비활성화
// swiftlint:disable force_cast
let cell1 = tableView.dequeueReusableCell(withIdentifier: "Cell1") as! CustomCell1
let cell2 = tableView.dequeueReusableCell(withIdentifier: "Cell2") as! CustomCell2
// swiftlint:enable force_cast
```

### 팀 규칙 문서화

`.swiftlint.yml` 파일에 규칙 설명 주석 추가:

```yaml
# 라인 길이를 120자로 제한 (가독성 향상)
line_length:
  warning: 120
  error: 150
```

### 사용자 정의 규칙 생성

복잡한 요구사항이 있다면 사용자 정의 규칙 생성:

```swift
// CustomRules.swift
import SwiftSyntax
import SwiftLintFramework

struct CustomMethodNameRule: Rule {
    // 규칙 구현...
}
```

이 가이드를 따라 토스뱅크 클론 프로젝트에 SwiftLint를 적용하면 코드 품질과 일관성을 크게 향상시킬 수 있습니다.
