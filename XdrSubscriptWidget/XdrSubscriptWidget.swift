//
//  XdrSubscriptWidget.swift
//  XdrSubscriptWidget
//
//  Created by Malovic, Milos on 4.2.23..
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), subscriptions: Subscription.example)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), subscriptions: getSubscriptions())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entrie = SimpleEntry.init(date: Date(), subscriptions: getSubscriptions())
        let timeline = Timeline(entries: [entrie], policy: .atEnd)
        completion(timeline)
    }
    
    private func getSubscriptions() -> [Subscription] {
        let controller = DataController()
        let fetch = Subscription.fetchRequest()
        fetch.sortDescriptors = []
        fetch.resultType = .managedObjectResultType
        let subscriptions = try? controller.container.viewContext.fetch(fetch) as [Subscription]
        return subscriptions ?? []
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let subscriptions: [Subscription]
}

struct XdrSubscriptWidget: Widget {
    let kind: String = "XdrSubscriptWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            XdrSubscriptWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Next To Pay")
        .description("Showing next subscription to pay")
        .supportedFamilies([.systemSmall])
    }
}

struct XdrSubscriptRecentWidget: Widget {
    let kind: String = "XdrSubscriptRecentWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RecentSubscriptionWidgetView(entry: entry)
        }
        .configurationDisplayName("Recent Subscriptions")
        .description("Showing last 3 added subcriptions")
        .supportedFamilies([.systemMedium])
    }
}


struct XdrSubscriptWidgetEntryView : View {
    
    var entry: Provider.Entry
    var selectedCurrency = UserDefaults(suiteName: .accessGroup)?.value(forKey: "selectedCurrency") as? String ?? (Locale.current.currencySymbol ?? "USD")
    
    var body: some View {
        ZStack {
            Color.secondaryBackgroundColor.opacity(0.5)
            VStack(alignment: .leading, spacing: 8) {
                let subscriptions = entry.subscriptions.filter({$0.movedToHistory == false})
                let dayLeftSubscriptions = nextSub(subscriptions: subscriptions) ?? []
                let dayLeftSub = dayLeftSubscriptions.sorted(by: {$0.daysLeft < $1.daysLeft}).first
                let sub  = dayLeftSub?.sub
                
                if let sub = sub {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 4) {
                            if let url = URL(string: "https://logo.clearbit.com/\(sub.imageUrl)"), let imageData = try? Data(contentsOf: url),
                               let uiImage = UIImage(data: imageData) {
                                
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .frame(width: 30, height: 30, alignment: .center)
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                            else {
                                if let letter = sub.name.first {
                                    ZStack(alignment: .center) {
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(Color.blue.opacity(0.4))
                                            .frame(width: 50, height: 50, alignment: .center)
                                        Text(String(letter))
                                            .font(.title2)
                                            .bold()
                                    }
                                }
                            }
                            Text(sub.name)
                                .fontWeight(.semibold)
                        }
                    }
                    Text(sub.price.formatted(.currency(code: selectedCurrency)))
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    if let dayLeftSub = dayLeftSub {
                        Text("\(dayLeftSub.daysLeft) day(s) left")
                            .font(.body14)
                            .fontWeight(.medium)
                            .foregroundColor(.primary.opacity(0.7))
                    }
                    HStack(alignment: .center) {
                        Text(sub.notificationOn ? "Notification on" : "Notification off")
                            .font(.body14)
                            .fontWeight(.medium)
                            .foregroundColor(.primary.opacity(0.7))
                        Image(systemName: sub.notificationOn ? "bell.fill" : "bell")
                            .font(.body14)
                            .fontWeight(.medium)
                            .foregroundColor(sub.notificationOn ? .indigo : .secondary)
                    }
                } else {
                    Text("Subcriptions will appear here.")
                }
            }
            .padding()
        }
    }
}

extension XdrSubscriptWidgetEntryView {
    
    func nextSub(subscriptions: [Subscription]) -> [DaysLeft]? {
        var daysLeftSubs: [DaysLeft] = []
        
        if !subscriptions.isEmpty {
            for subscription in subscriptions.filter({$0.movedToHistory == false}) {
                let comp = Calendar.current.dateComponents([.month, .day], from: subscription.startDate)
              
                let newDay = Calendar.current.date(from: comp)
                let dayInMonth = newDay!.day
                
                let now = Date()
                
                let c = Calendar.current.component(.year, from: now)
                
                var nextComp = DateComponents()
                nextComp.day = dayInMonth
                nextComp.month = Calendar.current.component(.month, from: now)
                nextComp.year = c

                let nowNextMonthDay = Calendar.current.date(from: nextComp)
                print("\(subscription.name) Now Next month day : \(String(describing: nowNextMonthDay))")
               
                let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: nowNextMonthDay!)
                print("\(subscription.name) Next month day: \(String(describing: nextMonth))")
           
                let dayLeft = Calendar.current.numberOf24DaysBetween(.now, and: nextMonth!)
                let d = DaysLeft.init(sub: subscription, daysLeft: dayLeft)
                daysLeftSubs.append(d)
            }
        }
        return daysLeftSubs.sorted(by: {$0.daysLeft < $1.daysLeft})
    }
}


struct RecentSubscriptionWidgetView: View {
    
    var entry: Provider.Entry
    var selectedCurrency = UserDefaults(suiteName: .accessGroup)?.value(forKey: "selectedCurrency") as? String ?? (Locale.current.currencySymbol ?? "USD")
    
    var body: some View {
       // GeometryReader { geo in
            VStack(alignment: .leading, spacing: 8) {
                let subscriptions = entry.subscriptions.filter({$0.movedToHistory == false}).prefix(3)
                let subs = Array(subscriptions)
                HStack(alignment: .top, spacing: 8) {
                    ForEach(subs, id: \.id) { sub in
                        VStack(alignment: .leading, spacing: 8) {
                            if let url = URL(string: "https://logo.clearbit.com/\(sub.imageUrl)"), let imageData = try? Data(contentsOf: url),
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .frame(width: 25, height: 25, alignment: .center)
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                            else {
                                if let letter = sub.name.first {
                                    ZStack(alignment: .center) {
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(Color.blue.opacity(0.4))
                                            .frame(width: 25, height: 25, alignment: .center)
                                        Text(String(letter))
                                            .font(.title2)
                                            .bold()
                                    }
                                }
                            }
                            Text(sub.name)
                                .fontWeight(.semibold)
                            Text(sub.price.formatted(.currency(code: selectedCurrency)))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                            Text(DateFormatter.localizedString(from: sub.startDate, dateStyle: .medium, timeStyle: .none))
                                .font(.caption2)
                                .foregroundColor(.primary.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity ,maxHeight: .infinity)
                        .padding()
                        .background(Color.secondaryBackgroundColor.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    Spacer()
                }
                .padding(4)
            }
       // }
    }
}

struct XdrSubscriptInfoWidgetView: View {
    
    var body: some View {
        VStack(alignment: .leading) {
            
        }
    }
    
}

