## 텍스트 스타일 규칙

텍스트 스타일은 `View+TextStyle.swift`의 `TextStyle` enum에 정의되어 있다.

1. **정의된 스타일 우선 사용**: 텍스트를 렌더링할 때는 `.textStyle(.xxx)` 를 우선 사용한다.

2. **스타일이 없을 경우 추가**: 필요한 스타일이 없으면 `TextStyle` enum에 새로운 케이스를 추가한다.

3. **kerning만 다를 경우 override 사용**: 기존 스타일과 `fontName`, `fontSize`, `lineHeight`가 동일하고 kerning만 다를 경우, 새 스타일을 추가하지 않고 기존 스타일에 `.kerning(X)`을 체이닝하여 구현한다.
   ```swift
   // 예시: caption2(Regular 12/20/-0.15)와 fontName/fontSize/lineHeight가 같고 kerning만 다른 경우
   Text("...")
     .textStyle(.caption2)
     .kerning(-0.2)
   ```
