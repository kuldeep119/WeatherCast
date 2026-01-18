
import SwiftUI

struct ForecastRow: View {
    let forecast: DailyForecast
    @AppStorage("temp_unit") private var unit: String = "C"
    
    var body: some View {
        HStack(spacing: 16) {
            // 1. Icon Section
            Image(systemName: forecast.icon)
                .font(.system(size: 28))
                .foregroundColor(forecast.icon.contains("rain") ? .blue : .orange)
                .frame(width: 50, height: 50)
                .background(Circle().fill(Color.white.opacity(0.4)))
            
            // 2. Date/Day Section
            VStack(alignment: .leading) {
                Text(forecast.day)
                    .font(.system(size: 16, weight: .medium))
                Text(forecast.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            //3. temperature section
            HStack(alignment: .top, spacing: 2) {
                Text("\(Int(forecast.temperature))")
                    .font(.system(size: 20, weight: .bold))
                Text("°\(unit)")
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.top, 2)
            }
            .foregroundColor(Color(white: 0.3))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        
    }
}

#Preview {
    ZStack {
        Color.blue.opacity(0.3).ignoresSafeArea()
        ForecastRow(forecast: DailyForecast(day: "Monday", date: "19 Jan", temperature: 28, icon: "sun.max.fill"))
            .padding()
    }
}
