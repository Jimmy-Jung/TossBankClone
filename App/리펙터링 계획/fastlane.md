
# 토스뱅크 클론 프로젝트 Fastlane 구축 가이드

## 1. Fastlane 설치

```bash
# Homebrew를 통한 설치
brew install fastlane

# 또는 Ruby gem을 통한 설치
gem install fastlane
```

## 2. Fastlane 초기화

```bash
# 프로젝트 루트 디렉토리로 이동
cd /Users/zundaeng/Documents/GitHub/TossBankClone

# Fastlane 초기화
fastlane init
```

초기화 과정에서 다음 질문에 답하세요:
- 앱 스토어에 앱이 있는지
- Apple ID 계정 정보
- 앱 식별자 (bundle identifier)

## 3. Fastlane 파일 구조 설정

```
TossBankClone/
  ├── fastlane/
  │   ├── Appfile            # 앱 식별자 및 Apple 계정 정보
  │   ├── Fastfile           # 레인 정의
  │   ├── Matchfile          # 인증서 및 프로비저닝 프로파일 관리
  │   └── Pluginfile         # 사용할 플러그인 목록
```

### Appfile 구성

```ruby
# fastlane/Appfile
app_identifier("com.tossbankclone") # 번들 ID
apple_id("your_apple_id@example.com") # Apple ID
team_id("YOUR_TEAM_ID") # 개발자 계정 팀 ID
```

### Fastfile 기본 구성

```ruby
# fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Run all tests"
  lane :tests do
    run_tests(
      workspace: "TossBankClone.xcworkspace",
      scheme: "TossBankClone",
      device: "iPhone 14",
      code_coverage: true
    )
  end

  desc "Build app for development"
  lane :build_dev do
    gym(
      workspace: "TossBankClone.xcworkspace",
      scheme: "TossBankClone",
      configuration: "Debug",
      export_method: "development",
      output_directory: "./builds",
      output_name: "TossBankClone-dev.ipa"
    )
  end

  desc "Build and upload to TestFlight"
  lane :beta do
    # 인증서 및 프로비저닝 프로파일 동기화
    match(type: "appstore")
    
    # 빌드 번호 자동 증가
    increment_build_number
    
    # 앱 빌드
    gym(
      workspace: "TossBankClone.xcworkspace",
      scheme: "TossBankClone",
      configuration: "Release",
      export_method: "app-store",
      output_directory: "./builds",
      output_name: "TossBankClone.ipa"
    )
    
    # TestFlight 업로드
    upload_to_testflight
  end

  desc "Build and upload to App Store"
  lane :release do
    # 인증서 및 프로비저닝 프로파일 동기화
    match(type: "appstore")
    
    # 버전 및 빌드 번호 관리
    increment_build_number
    
    # 앱 빌드
    gym(
      workspace: "TossBankClone.xcworkspace",
      scheme: "TossBankClone",
      configuration: "Release",
      export_method: "app-store",
      output_directory: "./builds",
      output_name: "TossBankClone.ipa"
    )
    
    # 앱스토어 업로드
    upload_to_app_store(
      force: true,
      skip_metadata: false,
      skip_screenshots: false,
      submit_for_review: false
    )
  end
end
```

## 4. Tuist 프로젝트와 Fastlane 통합

Tuist로 생성된 프로젝트를 Fastlane과 함께 사용하려면:

```ruby
# fastlane/Fastfile에 Tuist 통합 레인 추가
desc "Generate Xcode project using Tuist"
lane :generate_project do
  sh("tuist", "generate")
end

# 모든 레인에 generate_project 추가
lane :tests do
  generate_project
  run_tests(...)
end

lane :build_dev do
  generate_project
  gym(...)
end
```

## 5. 인증서 및 프로비저닝 프로파일 자동화 (match)

```bash
# match 설정
fastlane match init
```

```ruby
# fastlane/Matchfile
git_url("https://github.com/your-username/certificates.git")
storage_mode("git")
type("development") # 개발, appstore, adhoc 등

app_identifier(["com.tossbankclone"])
username("your_apple_id@example.com")

# 선택적: 키 암호화를 위한 비밀번호 환경변수
ENV["MATCH_PASSWORD"] = "your-encryption-password"
```

## 6. 환경별 빌드 설정

```ruby
# fastlane/Fastfile
# 개발환경 빌드
lane :build_dev do
  generate_project
  sh("cp", "../Config/dev.xcconfig", "../App/Config/Environment.xcconfig")
  gym(scheme: "TossBankClone", configuration: "Debug")
end

# 스테이징 환경 빌드
lane :build_staging do
  generate_project
  sh("cp", "../Config/staging.xcconfig", "../App/Config/Environment.xcconfig")
  gym(scheme: "TossBankClone", configuration: "Release")
end

# 프로덕션 환경 빌드
lane :build_production do
  generate_project
  sh("cp", "../Config/production.xcconfig", "../App/Config/Environment.xcconfig")
  gym(scheme: "TossBankClone", configuration: "Release")
end
```

## 7. CI/CD 파이프라인 통합

### GitHub Actions와 통합

```yaml
# .github/workflows/ios-ci.yml
name: iOS CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Ruby
      uses: ruby/setup-ruby@v1
      with:
        bundler-cache: true
    - name: Install dependencies
      run: |
        gem install bundler
        bundle install
        brew install tuist
    - name: Run tests
      run: bundle exec fastlane tests
  
  beta:
    needs: test
    if: github.event_name == 'push' && github.ref == 'refs/heads/develop'
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Ruby
      uses: ruby/setup-ruby@v1
      with:
        bundler-cache: true
    - name: Install dependencies
      run: |
        gem install bundler
        bundle install
        brew install tuist
    - name: Deploy to TestFlight
      run: bundle exec fastlane beta
      env:
        APPLE_ID: ${{ secrets.APPLE_ID }}
        APPLE_APP_SPECIFIC_PASSWORD: ${{ secrets.APPLE_APP_SPECIFIC_PASSWORD }}
        MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
        MATCH_GIT_BASIC_AUTHORIZATION: ${{ secrets.MATCH_GIT_BASIC_AUTHORIZATION }}
```

## 8. 유용한 Fastlane 플러그인 추가

```ruby
# fastlane/Pluginfile
gem 'fastlane-plugin-firebase_app_distribution'  # Firebase 배포용
gem 'fastlane-plugin-versioning'                # 버전 관리용
```

설치:
```bash
fastlane add_plugin firebase_app_distribution
fastlane add_plugin versioning
```

## 9. 실행 예제

```bash
# 테스트 실행
fastlane tests

# 개발 빌드
fastlane build_dev

# 테스트플라이트 배포
fastlane beta

# 앱스토어 배포
fastlane release
```

## 10. 팁과 베스트 프랙티스

1. **환경 변수 활용**: 민감한 정보는 환경 변수로 관리
   ```ruby
   app_identifier(ENV["APP_IDENTIFIER"])
   apple_id(ENV["APPLE_ID"])
   ```

2. **Gemfile 사용**: Ruby 의존성 관리
   ```ruby
   # Gemfile
   source "https://rubygems.org"
   gem "fastlane"
   ```

3. **출시 노트 자동화**:
   ```ruby
   lane :beta do
     changelog_from_git_commits(
       pretty: "- %s",
       date_format: "short",
       match_lightweight_tag: false,
       merge_commit_filtering: "exclude_merges"
     )
     upload_to_testflight(changelog: lane_context[SharedValues::FL_CHANGELOG])
   end
   ```

4. **슬랙 알림 통합**:
   ```ruby
   after_all do |lane|
     slack(message: "Successfully deployed new build to #{lane}")
   end
   
   error do |lane, exception|
     slack(message: "Failed to deploy: #{exception}")
   end
   ```

이 가이드를 따라 설정하면 토스뱅크 클론 프로젝트에 완전한 CI/CD 파이프라인을 구축할 수 있습니다.
