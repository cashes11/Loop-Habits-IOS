import SwiftUI
import Charts

// MARK: - Chart granularity

enum ChartGranularity: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case quarter = "Quarter"
    case year = "Year"

    var id: String { rawValue }
}

/// A single (date, value) point used by the score/history charts.
struct DatedValue: Identifiable {
    var id: Date { date }
    let date: Date
    let value: Double
}

/// One entry in the Best-streaks list.
struct Streak: Identifiable {
    let id = UUID()
    let start: Date
    let end: Date
    let length: Int
}

// MARK: - Habit Detail

struct HabitDetailView: View {
    let habitID: UUID
    @EnvironmentObject var habitStore: HabitStore

    @State private var scoreGranularity: ChartGranularity = .month
    @State private var historyGranularity: ChartGranularity = .week

    init(habit: Habit) {
        self.habitID = habit.id
    }

    /// The live habit from the store (so edits reflect immediately), with a
    /// freshly computed score history.
    private var scoredHabit: Habit? {
        guard var habit = habitStore.habits.first(where: { $0.id == habitID }) else { return nil }
        habit.recomputeScores()
        return habit
    }

    var body: some View {
        Group {
            if let habit = scoredHabit {
                content(for: habit)
            } else {
                Text("Habit not found")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle(scoredHabit?.name ?? "Habit")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func content(for habit: Habit) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HabitHeaderView(habit: habit)
                sectionDivider
                OverviewSection(habit: habit)
                sectionDivider
                ScoreSection(habit: habit, granularity: $scoreGranularity)
                sectionDivider
                HistorySection(habit: habit, granularity: $historyGranularity)
                sectionDivider
                CalendarSection(habit: habit)
                sectionDivider
                BestStreaksSection(habit: habit)
                sectionDivider
                FrequencySection(habit: habit)
            }
            .padding(.vertical)
        }
    }

    private var sectionDivider: some View {
        Divider().padding(.vertical, 10)
    }
}

// MARK: - Header

struct HabitHeaderView: View {
    let habit: Habit

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !habit.question.isEmpty {
                Text(habit.question)
                    .font(.headline)
                    .foregroundColor(habit.colorValue)
            }
            Label(frequencySummary(habit), systemImage: "calendar")
                .font(.subheadline)
                .foregroundColor(.secondary)
            if !habit.description.isEmpty {
                Text(habit.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}

// MARK: - Overview

struct OverviewSection: View {
    let habit: Habit

    private var current: Double { habit.getCurrentScore() }
    private var monthDelta: Double { current - habit.getScore(for: Timestamp.today().minus(30)) }
    private var yearDelta: Double { current - habit.getScore(for: Timestamp.today().minus(365)) }
    private var total: Int { habit.entries.filter { habit.isCompletedOn($0.timestamp) }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle("Overview", color: habit.colorValue)

            HStack(spacing: 20) {
                ScoreRing(score: current, color: habit.colorValue)
                    .frame(width: 52, height: 52)

                statColumn(pct(current), "Score", color: habit.colorValue)
                statColumn(signedPct(monthDelta), "Month", color: .secondary)
                statColumn(signedPct(yearDelta), "Year", color: .secondary)
                statColumn("\(total)", "Total", color: habit.colorValue)
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal)
    }

    private func statColumn(_ value: String, _ label: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.subheadline).bold().foregroundColor(color)
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
    }
}

struct ScoreRing: View {
    let score: Double
    let color: Color

    var body: some View {
        ZStack {
            Circle().stroke(Color.gray.opacity(0.2), lineWidth: 6)
            Circle()
                .trim(from: 0, to: max(0.001, min(1, score)))
                .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - Score

struct ScoreSection: View {
    let habit: Habit
    @Binding var granularity: ChartGranularity

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionTitle("Score", color: habit.colorValue)
                Spacer()
                GranularityMenu(selection: $granularity, options: ChartGranularity.allCases)
            }

            let data = scoreSeries(for: habit, granularity: granularity)
            Chart(data) { point in
                AreaMark(x: .value("Date", point.date), y: .value("Score", point.value))
                    .foregroundStyle(LinearGradient(colors: [habit.colorValue.opacity(0.25), .clear],
                                                    startPoint: .top, endPoint: .bottom))
                    .interpolationMethod(.catmullRom)
                LineMark(x: .value("Date", point.date), y: .value("Score", point.value))
                    .foregroundStyle(habit.colorValue)
                    .interpolationMethod(.catmullRom)
                PointMark(x: .value("Date", point.date), y: .value("Score", point.value))
                    .foregroundStyle(habit.colorValue)
                    .symbolSize(18)
            }
            .chartYScale(domain: 0...1)
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 0.25, 0.5, 0.75, 1.0]) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let d = value.as(Double.self) {
                            Text("\(Int(d * 100))%").font(.caption2)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: xAxisFormat(granularity))
                }
            }
            .frame(height: 200)
        }
        .padding(.horizontal)
    }
}

// MARK: - History

struct HistorySection: View {
    let habit: Habit
    @Binding var granularity: ChartGranularity

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionTitle("History", color: habit.colorValue)
                Spacer()
                GranularityMenu(selection: $granularity,
                                options: [.week, .month, .quarter, .year])
            }

            let data = historySeries(for: habit, granularity: granularity)
            Chart(data) { point in
                BarMark(x: .value("Date", point.date), y: .value("Count", point.value))
                    .foregroundStyle(habit.colorValue)
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: xAxisFormat(granularity))
                }
            }
            .frame(height: 180)
        }
        .padding(.horizontal)
    }
}

// MARK: - Calendar (heatmap)

struct CalendarSection: View {
    let habit: Habit
    @EnvironmentObject var habitStore: HabitStore
    @State private var numberTimestamp: Timestamp?

    private let weeksToShow = 26
    private let cellSize: CGFloat = 16
    private let cellSpacing: CGFloat = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle("Calendar", color: habit.colorValue)

            HStack(alignment: .top, spacing: 6) {
                // Fixed weekday labels (Sun … Sat)
                VStack(spacing: cellSpacing) {
                    ForEach(0..<7, id: \.self) { day in
                        Text(["S", "M", "T", "W", "T", "F", "S"][day])
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                            .frame(height: cellSize)
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: cellSpacing) {
                        ForEach(weekColumns(), id: \.self) { weekStart in
                            VStack(spacing: cellSpacing) {
                                ForEach(0..<7, id: \.self) { weekday in
                                    calendarCell(weekStart: weekStart, weekday: weekday)
                                }
                            }
                        }
                    }
                    .padding(.trailing, 4)
                }
                .defaultScrollAnchor(.trailing)
            }
        }
        .padding(.horizontal)
        .sheet(item: $numberTimestamp) { timestamp in
            NumberEntrySheet(habit: habit, timestamp: timestamp)
        }
    }

    private func weekColumns() -> [Timestamp] {
        let calendar = Calendar.current
        let sunday = startOfWeekSunday(Date(), calendar: calendar)
        return (0..<weeksToShow).reversed().compactMap { back in
            guard let date = calendar.date(byAdding: .weekOfYear, value: -back, to: sunday) else { return nil }
            return Timestamp.fromDate(calendar.startOfDay(for: date))
        }
    }

    private func calendarCell(weekStart: Timestamp, weekday: Int) -> some View {
        let date = weekStart.plus(weekday)
        let isFuture = date.unixTime > Timestamp.today().unixTime
        let completed = habit.isCompletedOn(date)
        let skipped = habit.getEntry(for: date).isSkip

        return RoundedRectangle(cornerRadius: 3)
            .fill(fillColor(isFuture: isFuture, completed: completed, skipped: skipped))
            .frame(width: cellSize, height: cellSize)
            .contentShape(Rectangle())
            .onTapGesture {
                guard !isFuture else { return }
                if habit.type == .NUMERICAL {
                    numberTimestamp = date
                } else {
                    habitStore.toggleEntry(for: habit, on: date)
                }
            }
    }

    private func fillColor(isFuture: Bool, completed: Bool, skipped: Bool) -> Color {
        if isFuture { return .clear }
        if completed { return habit.colorValue }
        if skipped { return habit.colorValue.opacity(0.3) }
        return Color.gray.opacity(0.15)
    }
}

// MARK: - Best streaks

struct BestStreaksSection: View {
    let habit: Habit

    var body: some View {
        let streaks = bestStreaks(for: habit, limit: 10)

        return VStack(alignment: .leading, spacing: 14) {
            SectionTitle("Best streaks", color: habit.colorValue)

            if streaks.isEmpty {
                Text("No streaks yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                let maxLength = streaks.map { $0.length }.max() ?? 1
                VStack(spacing: 8) {
                    ForEach(streaks) { streak in
                        HStack(spacing: 8) {
                            Text(shortDate(streak.start))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(width: 78, alignment: .trailing)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.15))
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(habit.colorValue.opacity(0.85))
                                        .frame(width: max(20, geo.size.width * CGFloat(streak.length) / CGFloat(maxLength)))
                                    Text("\(streak.length)")
                                        .font(.caption2).bold()
                                        .foregroundColor(.white)
                                        .padding(.leading, 8)
                                }
                            }
                            .frame(height: 20)

                            Text(shortDate(streak.end))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(width: 78, alignment: .leading)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Frequency matrix

struct FrequencySection: View {
    let habit: Habit

    private let monthsToShow = 13

    var body: some View {
        let matrix = frequencyMatrix(for: habit, months: monthsToShow)
        let maxCount = matrix.flatMap { $0 }.max() ?? 1

        return VStack(alignment: .leading, spacing: 14) {
            SectionTitle("Frequency", color: habit.colorValue)

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 6) {
                    ForEach(0..<7, id: \.self) { weekday in
                        HStack(spacing: 10) {
                            ForEach(0..<monthsToShow, id: \.self) { month in
                                let count = matrix[month][weekday]
                                ZStack {
                                    Circle()
                                        .fill(habit.colorValue)
                                        .frame(width: dotSize(count, max: maxCount),
                                               height: dotSize(count, max: maxCount))
                                }
                                .frame(width: 20, height: 20)
                            }
                            Text(weekdayLabel(weekday))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(width: 32, alignment: .leading)
                        }
                    }

                    // Month labels
                    HStack(spacing: 10) {
                        ForEach(0..<monthsToShow, id: \.self) { month in
                            Text(monthLabel(monthsBack: monthsToShow - 1 - month))
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                                .frame(width: 20)
                        }
                        Spacer().frame(width: 32)
                    }
                }
                .padding(.trailing, 4)
            }
            .defaultScrollAnchor(.trailing)
        }
        .padding(.horizontal)
    }

    private func dotSize(_ count: Int, max: Int) -> CGFloat {
        guard count > 0, max > 0 else { return 0 }
        let fraction = CGFloat(count) / CGFloat(max)
        return 5 + fraction * 13   // 5 … 18 pt
    }
}

// MARK: - Shared bits

struct SectionTitle: View {
    let text: String
    let color: Color
    init(_ text: String, color: Color) {
        self.text = text
        self.color = color
    }
    var body: some View {
        Text(text).font(.title3).bold().foregroundColor(color)
    }
}

struct GranularityMenu: View {
    @Binding var selection: ChartGranularity
    let options: [ChartGranularity]

    var body: some View {
        Menu {
            ForEach(options) { option in
                Button(option.rawValue) { selection = option }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selection.rawValue)
                Image(systemName: "chevron.down").font(.caption2)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }
}

// Needed by `.sheet(item:)` in both the home grid and the calendar.
extension Timestamp: Identifiable {
    public var id: Int64 { unixTime }
}

// MARK: - Data helpers

private func frequencySummary(_ habit: Habit) -> String {
    let n = habit.frequencyNumerator
    let d = habit.frequencyDenominator
    if n == 1 && d == 1 { return "Every day" }
    if d == 7 { return "\(n) times per week" }
    if d == 30 || d == 31 { return "\(n) times per month" }
    if n == 1 { return "Every \(d) days" }
    return "\(n) times per \(d) days"
}

private func pct(_ value: Double) -> String {
    "\(Int((value * 100).rounded()))%"
}

private func signedPct(_ value: Double) -> String {
    let p = Int((value * 100).rounded())
    return (p >= 0 ? "+" : "") + "\(p)%"
}

private func shortDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter.string(from: date)
}

private func weekdayLabel(_ weekday: Int) -> String {
    ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][weekday]
}

private func monthLabel(monthsBack: Int) -> String {
    let calendar = Calendar.current
    guard let date = calendar.date(byAdding: .month, value: -monthsBack, to: Date()) else { return "" }
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM"
    return formatter.string(from: date)
}

private func xAxisFormat(_ granularity: ChartGranularity) -> Date.FormatStyle {
    switch granularity {
    case .day, .week: return .dateTime.month(.abbreviated).day()
    case .month: return .dateTime.month(.abbreviated)
    case .quarter: return .dateTime.month(.abbreviated).year(.twoDigits)
    case .year: return .dateTime.year()
    }
}

private func startOfWeekSunday(_ date: Date, calendar: Calendar) -> Date {
    var cal = calendar
    cal.firstWeekday = 1 // Sunday
    let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
    return cal.date(from: comps) ?? cal.startOfDay(for: date)
}

private func startOfPeriod(_ date: Date, granularity: ChartGranularity, calendar: Calendar) -> Date {
    switch granularity {
    case .day:
        return calendar.startOfDay(for: date)
    case .week:
        return startOfWeekSunday(date, calendar: calendar)
    case .month:
        return calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    case .quarter:
        let comps = calendar.dateComponents([.year, .month], from: date)
        let quarterStartMonth = (((comps.month ?? 1) - 1) / 3) * 3 + 1
        var start = DateComponents()
        start.year = comps.year
        start.month = quarterStartMonth
        start.day = 1
        return calendar.date(from: start) ?? date
    case .year:
        return calendar.date(from: calendar.dateComponents([.year], from: date)) ?? date
    }
}

private func advancePeriod(_ date: Date, granularity: ChartGranularity, step: Int, calendar: Calendar) -> Date {
    switch granularity {
    case .day: return calendar.date(byAdding: .day, value: step, to: date) ?? date
    case .week: return calendar.date(byAdding: .weekOfYear, value: step, to: date) ?? date
    case .month: return calendar.date(byAdding: .month, value: step, to: date) ?? date
    case .quarter: return calendar.date(byAdding: .month, value: step * 3, to: date) ?? date
    case .year: return calendar.date(byAdding: .year, value: step, to: date) ?? date
    }
}

/// Start dates for the most recent `count` periods, oldest first.
private func periodStarts(count: Int, granularity: ChartGranularity, calendar: Calendar) -> [Date] {
    let current = startOfPeriod(Date(), granularity: granularity, calendar: calendar)
    var starts: [Date] = []
    for i in 0..<count {
        starts.append(advancePeriod(current, granularity: granularity, step: -i, calendar: calendar))
    }
    return starts.reversed()
}

/// Score sampled at the last day of each period (clamped to today), oldest → newest.
private func scoreSeries(for habit: Habit, granularity: ChartGranularity) -> [DatedValue] {
    let calendar = Calendar.current
    let counts: [ChartGranularity: Int] = [.day: 60, .week: 20, .month: 15, .quarter: 12, .year: 6]
    let count = counts[granularity] ?? 15
    let today = Timestamp.today()

    return periodStarts(count: count, granularity: granularity, calendar: calendar).map { start in
        let end = advancePeriod(start, granularity: granularity, step: 1, calendar: calendar)
        let lastDay = calendar.date(byAdding: .day, value: -1, to: end) ?? start
        var sample = Timestamp.fromDate(calendar.startOfDay(for: lastDay))
        if sample.unixTime > today.unixTime { sample = today }
        return DatedValue(date: start, value: habit.getScore(for: sample))
    }
}

/// Number of completions within each period, oldest → newest.
private func historySeries(for habit: Habit, granularity: ChartGranularity) -> [DatedValue] {
    let calendar = Calendar.current
    let counts: [ChartGranularity: Int] = [.week: 16, .month: 12, .quarter: 8, .year: 5]
    let count = counts[granularity] ?? 12

    let completed = habit.entries
        .filter { habit.isCompletedOn($0.timestamp) }
        .map { $0.timestamp.toDate() }

    return periodStarts(count: count, granularity: granularity, calendar: calendar).map { start in
        let end = advancePeriod(start, granularity: granularity, step: 1, calendar: calendar)
        let value = completed.filter { $0 >= start && $0 < end }.count
        return DatedValue(date: start, value: Double(value))
    }
}

/// All completion streaks, longest first, up to `limit`. Skipped days keep a
/// streak alive but do not extend its length.
private func bestStreaks(for habit: Habit, limit: Int) -> [Streak] {
    guard let first = habit.entries.map({ $0.timestamp }).min() else { return [] }
    let today = Timestamp.today()

    var streaks: [Streak] = []
    var runStart: Timestamp?
    var runEnd: Timestamp?
    var length = 0

    var day = first
    while day.unixTime <= today.unixTime {
        if habit.isCompletedOn(day) {
            if runStart == nil { runStart = day }
            runEnd = day
            length += 1
        } else if habit.getEntry(for: day).isSkip {
            // keeps the streak alive, no change to length
        } else {
            if let s = runStart, let e = runEnd, length > 0 {
                streaks.append(Streak(start: s.toDate(), end: e.toDate(), length: length))
            }
            runStart = nil; runEnd = nil; length = 0
        }
        day = day.plus(1)
    }
    if let s = runStart, let e = runEnd, length > 0 {
        streaks.append(Streak(start: s.toDate(), end: e.toDate(), length: length))
    }

    return Array(streaks.sorted { $0.length > $1.length }.prefix(limit))
}

/// completions[monthColumn][weekday] where column 0 is the oldest month shown.
private func frequencyMatrix(for habit: Habit, months: Int) -> [[Int]] {
    let calendar = Calendar.current
    let now = Date()
    var result = Array(repeating: Array(repeating: 0, count: 7), count: months)

    let completed = habit.entries.filter { habit.isCompletedOn($0.timestamp) }
    for entry in completed {
        let date = entry.timestamp.toDate()
        let from = calendar.dateComponents([.year, .month], from: date)
        let to = calendar.dateComponents([.year, .month], from: now)
        let monthsBack = ((to.year ?? 0) - (from.year ?? 0)) * 12 + ((to.month ?? 0) - (from.month ?? 0))
        guard monthsBack >= 0, monthsBack < months else { continue }
        let column = months - 1 - monthsBack
        let weekday = calendar.component(.weekday, from: date) - 1 // 0 = Sunday
        result[column][weekday] += 1
    }
    return result
}
