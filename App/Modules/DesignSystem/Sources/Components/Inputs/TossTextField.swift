import SwiftUI

/// 앱 전체에서 사용하는 텍스트 필드 컴포넌트
public struct TossTextField: View {
    // MARK: - 속성
    private let title: String
    private let placeholder: String
    private let keyboardType: UIKeyboardType
    private let isSecure: Bool
    private let maxLength: Int?
    private let validation: ((String) -> Bool)?
    private let onEditingChanged: ((Bool) -> Void)?
    
    @Binding private var text: String
    @State private var isFocused: Bool = false
    @State private var isValid: Bool = true
    
    @Environment(\.typographyStyle) private var typography
    
    // MARK: - 생성자
    public init(
        title: String,
        placeholder: String = "",
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false,
        maxLength: Int? = nil,
        validation: ((String) -> Bool)? = nil,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.keyboardType = keyboardType
        self.isSecure = isSecure
        self.maxLength = maxLength
        self.validation = validation
        self.onEditingChanged = onEditingChanged
    }
    
    // MARK: - 바디
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 제목
            Text(title)
                .font(typography.caption1)
                .foregroundColor(ColorTokens.Text.secondary)
                .padding(.leading, 4)
            
            // 텍스트 필드
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(getBorderColor(), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ColorTokens.Background.secondary)
                    )
                
                HStack {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                            .onChange(of: text) { newValue in
                                limitTextLength(newValue)
                                validateText()
                            }
                            .onAppear {
                                validateText()
                            }
                    } else {
                        TextField(placeholder, text: $text, onEditingChanged: { editing in
                            isFocused = editing
                            onEditingChanged?(editing)
                        })
                        .keyboardType(keyboardType)
                        .onChange(of: text) { newValue in
                            limitTextLength(newValue)
                            validateText()
                        }
                        .onAppear {
                            validateText()
                        }
                    }
                    
                    // 텍스트가 있고 포커스 상태일 때 클리어 버튼 표시
                    if !text.isEmpty && isFocused {
                        Button(action: {
                            text = ""
                            validateText()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(ColorTokens.Text.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .frame(height: 56)
            
            // 유효성 검사 실패 시 에러 메시지
            if !isValid {
                Text("올바른 형식으로 입력해주세요")
                    .font(typography.caption2)
                    .foregroundColor(ColorTokens.State.error)
                    .padding(.leading, 4)
            }
        }
    }
    
    // MARK: - 헬퍼 메서드
    private func getBorderColor() -> Color {
        if !isValid {
            return ColorTokens.State.error
        }
        
        return isFocused ? ColorTokens.Brand.primary : ColorTokens.Border.primary
    }
    
    private func limitTextLength(_ value: String) {
        if let maxLength = maxLength, value.count > maxLength {
            text = String(value.prefix(maxLength))
        }
    }
    
    private func validateText() {
        if let validation = validation {
            isValid = validation(text)
        }
    }
}

// MARK: - 텍스트 필드 미리보기
struct TossTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            TossTextField(
                title: "이메일",
                placeholder: "이메일을 입력하세요",
                text: .constant(""),
                keyboardType: .emailAddress,
                validation: { text in
                    text.contains("@") || text.isEmpty
                }
            )
            
            TossTextField(
                title: "비밀번호",
                placeholder: "비밀번호를 입력하세요",
                text: .constant(""),
                isSecure: true
            )
            
            TossTextField(
                title: "계좌번호",
                placeholder: "숫자만 입력하세요",
                text: .constant("123456789"),
                keyboardType: .numberPad,
                maxLength: 14
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 