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
        colors: [
          Color(red: 0.08, green: 0.08, blue: 0.09),
          Color(red: 0.00, green: 0.00, blue: 0.00),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )

      VStack(alignment: .leading, spacing: 10) {
        HStack {
          Text("Pie Program")
            .font(.system(.caption, design: .rounded, weight: .bold))
            .foregroundStyle(.white.opacity(0.72))
          Spacer()
          Circle()
            .fill(Color(red: 0.20, green: 0.84, blue: 1.0))
            .frame(width: 8, height: 8)
        }

        HStack {
          ZStack {
            Circle()
              .stroke(Color(red: 0.20, green: 0.84, blue: 1.0).opacity(0.18), lineWidth: 7)
            Circle()
              .trim(from: 0, to: entry.progress)
              .stroke(Color(red: 0.20, green: 0.84, blue: 1.0), style: StrokeStyle(lineWidth: 7, lineCap: .round))
              .rotationEffect(.degrees(-90))
          }
          .frame(width: 48, height: 48)

          VStack(alignment: .leading, spacing: 3) {
            Text(entry.currentTask)
              .font(.system(.headline, design: .rounded, weight: .heavy))
              .foregroundStyle(.white)
              .lineLimit(1)
            Text(entry.remaining)
              .font(.system(.caption, design: .rounded, weight: .bold))
              .foregroundStyle(.white.opacity(0.68))
          }
        }
        Spacer(minLength: 0)
      }
      .padding(12)
    }
    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
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
