import SwiftUI

struct AddProposalDateTimeView: View {
  private let initialDraft: AddProposalDraft
  let onBack: () -> Void
  let onNext: (AddProposalDraft) -> Void

  @State private var currentMonth: Date
  @State private var selectedDate: Date
  @State private var isAM: Bool
  @State private var selectedHour: Int
  @State private var selectedMinute: Int

  private let calendar = Calendar.current
  private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

  init(
    draft: AddProposalDraft = AddProposalDraft(),
    onBack: @escaping () -> Void = {},
    onNext: @escaping (AddProposalDraft) -> Void = { _ in }
  ) {
    initialDraft = draft
    self.onBack = onBack
    self.onNext = onNext

    let cal = Calendar.current
    let seed = draft.deadline ?? Date()
    _currentMonth = State(initialValue: seed)
    _selectedDate = State(initialValue: seed)

    let hour24 = cal.component(.hour, from: seed)
    _isAM = State(initialValue: hour24 < 12)
    _selectedHour = State(initialValue: Self.toHour12(hour24: hour24))
    _selectedMinute = State(initialValue: cal.component(.minute, from: seed))
  }

  var body: some View {
    VStack(spacing: 0) {
      headerSection

      ScrollView {
        VStack(spacing: 24) {
          calendarSection
          timeSection
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
      }

      BottomActionBar(title: "다음") {
        var updated = initialDraft
        updated.deadline = composedDate()
        onNext(updated)
      }
    }
    .background(Color.gray000)
    .navigationBarHidden(true)
  }

  private var headerSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      AppBar(isProgress: true, onBack: onBack)

      VStack(alignment: .leading, spacing: 8) {
        Text("날짜 / 시간 설정")
          .textStyle(.heading3)
          .foregroundColor(Color.gray900)
          .padding(.horizontal, 16)

        Text("채팅을 통해 날짜와 시간을 조정할 수 있어요")
          .textStyle(.body3)
          .foregroundColor(Color.gray600)
          .padding(.horizontal, 16)
      }
    }
    .padding(.bottom, 32)
    .overlay(alignment: .bottom) {
      Rectangle()
        .fill(Color.gray200)
        .frame(height: 1)
    }
  }

  private var calendarSection: some View {
    VStack(spacing: 4) {
      monthNavigationRow

      weekdayHeaderRow

      daysGrid
    }
  }

  private var monthNavigationRow: some View {
    HStack(spacing: 6) {
      Button {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
      } label: {
        Image("icon_arrow_left")
          .renderingMode(.template)
          .resizable()
          .scaledToFit()
          .frame(width: 20, height: 20)
          .foregroundColor(Color.gray200)
      }
      .padding(10)

      Text(monthYearString)
        .textStyle(.title2)
        .kerning(-0.1)
        .foregroundColor(Color.gray900)

      Button {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
      } label: {
        Image("icon_arrow_right")
          .renderingMode(.template)
          .resizable()
          .scaledToFit()
          .frame(width: 20, height: 20)
          .foregroundColor(Color.gray900)
      }
      .padding(10)
    }
    .frame(maxWidth: .infinity)
  }

  private var weekdayHeaderRow: some View {
    HStack(spacing: 8) {
      ForEach(weekdays, id: \.self) { day in
        Text(day)
          .textStyle(.caption2)
          .kerning(-0.2)
          .foregroundColor(Color.gray600)
          .frame(maxWidth: .infinity)
          .frame(height: 40)
      }
    }

    .padding(.horizontal, 15)
  }

  private var daysGrid: some View {
    let days = daysInMonth()
    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    return LazyVGrid(columns: columns, spacing: 0) {
      ForEach(0 ..< days.count, id: \.self) { index in
        if let date = days[index] {
          dayCell(date: date)
        } else {
          Color.clear.frame(height: 40)
        }
      }
    }
    .padding(.horizontal, 15)
  }

  private func dayCell(date: Date) -> some View {
    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
    let isPast = date < calendar.startOfDay(for: Date())
    let isToday = calendar.isDateInToday(date)

    return Button {
      if !isPast {
        selectedDate = date
      }
    } label: {
      Text("\(calendar.component(.day, from: date))")
        .textStyle(.title2)
        .kerning(-0.2)
        .foregroundColor(dayTextColor(isSelected: isSelected, isPast: isPast, isToday: isToday))
        .frame(width: 40, height: 40)
        .background(isSelected ? Color.indigo500 : Color.clear)
        .clipShape(Circle())
    }
    .buttonStyle(.plain)
    .disabled(isPast)
  }

  private func dayTextColor(isSelected: Bool, isPast: Bool, isToday: Bool) -> Color {
    if isSelected {
      return .white
    }
    if isPast {
      return Color.gray200
    }
    if isToday {
      return Color.rose400
    }
    return Color.gray800
  }

  private var timeSection: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("시간")
        .textStyle(.body2, weight: .bold)
        .foregroundColor(Color.gray800)
        .padding(.horizontal, 8)
        .padding(.bottom, 10)

      amPmToggle

      timeScrollPicker
    }
  }

  private var amPmToggle: some View {
    HStack(spacing: 0) {
      Button { isAM = true } label: {
        Text("오전")
          .textStyle(.body1)
          .kerning(-0.2)
          .foregroundColor(isAM ? Color.gray900 : Color.gray500)
          .frame(maxWidth: .infinity)
          .frame(height: 36)
          .background(isAM ? Color.white : Color.gray100)
          .clipShape(RoundedRectangle(cornerRadius: 8))
      }
      .buttonStyle(.plain)

      Button { isAM = false } label: {
        Text("오후")
          .textStyle(.body1)
          .kerning(-0.2)
          .foregroundColor(!isAM ? Color.gray900 : Color.gray500)
          .frame(maxWidth: .infinity)
          .frame(height: 36)
          .background(!isAM ? Color.white : Color.gray100)
          .clipShape(RoundedRectangle(cornerRadius: 8))
      }
      .buttonStyle(.plain)
    }
    .padding(6)
    .background(Color.gray100)
    .clipShape(RoundedRectangle(cornerRadius: 10))
  }

  private var timeScrollPicker: some View {
    ZStack(alignment: .center) {
      Color.gray100
        .frame(height: 47)
        
      HStack(spacing: 8) {
        TimePickerColumn(values: Array(1 ... 12), selection: $selectedHour, format: "%02d")
        TimePickerColumn(values: Array(0 ... 59), selection: $selectedMinute, format: "%02d")
      }
      .padding(.horizontal, 80)
    }
    .padding(.vertical, 16)
  }

  private struct TimePickerColumn: View {
    let values: [Int]
    @Binding var selection: Int
    let format: String

    @GestureState private var dragOffset: CGFloat = 0
    private let rowHeight: CGFloat = 31

    private var currentIndex: Int {
      values.firstIndex(of: selection) ?? 0
    }

    var body: some View {
      VStack(alignment: .leading, spacing: 12) {
        ForEach(-2 ... 2, id: \.self) { offset in
          let idx = (currentIndex + offset + values.count * 100) % values.count
          Text(String(format: format, values[idx]))
            .textStyle(.body1)
            .kerning(-0.2)
            .foregroundColor(offset == 0 ? Color.gray900 : Color.gray300)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
      }
      .offset(y: dragOffset)
      .animation(.easeOut(duration: 0.15), value: selection)
      .frame(height: 130)
      .clipped()
      .gesture(
        DragGesture()
          .updating($dragOffset) { value, state, _ in
            state = value.translation.height
          }
          .onEnded { value in
            let steps = -Int((value.translation.height / rowHeight).rounded())
            let newIdx = (currentIndex + steps + values.count * 100) % values.count
            selection = values[newIdx]
          }
      )
    }
  }

  // MARK: - Helpers

  private func composedDate() -> Date {
    let hour24: Int
    if isAM {
      hour24 = selectedHour == 12 ? 0 : selectedHour
    } else {
      hour24 = selectedHour == 12 ? 12 : selectedHour + 12
    }
    return calendar.date(
      bySettingHour: hour24,
      minute: selectedMinute,
      second: 0,
      of: selectedDate
    ) ?? selectedDate
  }

  private static func toHour12(hour24: Int) -> Int {
    if hour24 == 0 {
      return 12
    }
    if hour24 > 12 {
      return hour24 - 12
    }
    return hour24
  }

  private var monthYearString: String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "yyyy년 M월"
    return formatter.string(from: currentMonth)
  }

  private func daysInMonth() -> [Date?] {
    let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
    let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1
    let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)!.count

    var days: [Date?] = Array(repeating: nil, count: firstWeekday)
    for day in 0 ..< daysInMonth {
      days.append(calendar.date(byAdding: .day, value: day, to: firstOfMonth))
    }
    // 7의 배수로 채우기
    while days.count % 7 != 0 {
      days.append(nil)
    }
    return days
  }
}

#Preview {
  AddProposalDateTimeView(draft: AddProposalDraft(title: "샘플", content: "내용"))
}
