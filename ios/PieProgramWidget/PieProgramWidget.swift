import SwiftUI
import WidgetKit

private let appGroup = "group.com.fortune.cooking.fortune.pie"

struct PieProgramEntry: TimelineEntry {
  let date: Date
  let currentTask: String
  let remaining: String
  let progress: Double
}

struct PieProgramProvider: TimelineProvider {
  func placeholder(in context: Context) -> PieProgramEntry {
    PieProgramEntry(date: Date(), currentTask: "Focus", remaining: "35m", progress: 0.4)
  }

  func getSnapshot(in context: Context, completion: @escaping (PieProgramEntry) -> Void) {
    completion(loadEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<PieProgramEntry>) -> Void) {
    let entry = loadEntry()
    let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
    completion(Timeline(entries: [entry], policy: .after(next)))
  }

  private func loadEntry() -> PieProgramEntry {
    let defaults = UserDefaults(suiteName: appGroup)
    let task = defaults?.string(forKey: "pie_current_task") ?? "No task"
    let remaining = defaults?.string(forKey: "pie_remaining") ?? "0m"
    let progress = defaults?.double(forKey: "pie_progress") ?? 0

    return PieProgramEntry(
      date: Date(),
      currentTask: task,
      remaining: remaining,
      progress: min(max(progress, 0), 1)
    )
  }
}

struct PieProgramWidgetEntryView: View {
  let entry: PieProgramProvider.Entry

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [Color(red: 0.07, green: 0.19, blue: 0.33), Color(red: 0.05, green: 0.11, blue: 0.19)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )

      VStack(alignment: .leading, spacing: 8) {
        Text("Pie Program")
          .font(.caption)
          .foregroundStyle(.white.opacity(0.85))

        HStack {
          ZStack {
            Circle()
              .stroke(Color.white.opacity(0.2), lineWidth: 6)
            Circle()
              .trim(from: 0, to: entry.progress)
              .stroke(Color.cyan, style: StrokeStyle(lineWidth: 6, lineCap: .round))
              .rotationEffect(.degrees(-90))
          }
          .frame(width: 44, height: 44)

          VStack(alignment: .leading, spacing: 2) {
            Text(entry.currentTask)
              .font(.headline)
              .foregroundStyle(.white)
              .lineLimit(1)
            Text(entry.remaining)
              .font(.caption)
              .foregroundStyle(.white.opacity(0.8))
          }
        }
      }
      .padding(12)
    }
    .widgetURL(URL(string: "fortune://app/pie-program"))
  }
}

struct PieProgramWidget: Widget {
  let kind = "PieProgramWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: PieProgramProvider()) { entry in
      PieProgramWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Pie Program")
    .description("Current block, time remaining and progress ring.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
