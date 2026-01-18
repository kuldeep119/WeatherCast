
import SwiftUI

// MARK: - Detail View
struct DetailView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("temp_unit") private var unit: String = "C"
    let weather: WeatherData
    @State private var selectedMetric = "Temperature"
    
    var body: some View {
        ZStack {
            Color(white: 0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Main Info Card
                VStack(spacing: 0) {
                    // Weekly strip logic
                    HStack(spacing: 0) {
                        ForEach(["T", "F", "S", "S", "M", "T", "W", "T"], id: \.self) { day in
                            Text(day)
                                .font(.system(size: 14))
                                .foregroundColor(Color(white: 0.5))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical, 20)
                    
                    Divider()
                        .background(Color(white: 0.8))
                    
                    // Current Metrics Selection Row
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current View")
                                .font(.system(size: 14))
                                .foregroundColor(Color(white: 0.5))
                        }
                        
                        Spacer()
                        
                        // Metric Selector Menu
                        Menu {
                            Button("Temperature") { selectedMetric = "Temperature" }
                            Button("Humidity") { selectedMetric = "Humidity" }
                            Button("Wind") { selectedMetric = "Wind" }
                        } label: {
                            metricSelectorLabel
                        }
                    }
                    .padding(20)
                    
                    // FIXED: Dynamic Chart
                    // We only call this once, and we use the dynamic data/color variables
                    TemperatureChart(hourlyData: currentChartData, color: chartColor)
                        .id(selectedMetric) // Forces animation & refresh on change
                        .frame(height: 200)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    
                    // Forecast Description
                    descriptionView
                }
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white)
                )
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
    
    // MARK: - Computed Properties for Dynamic Graph
    private var currentChartData: [HourlyTemp] {
        switch selectedMetric {
        case "Temperature": return weather.hourlyTemperatures
        case "Humidity":    return weather.hourlyHumidity
        case "Wind":        return weather.hourlyWindSpeed
        default:            return weather.hourlyTemperatures
        }
    }

    private var chartColor: Color {
        switch selectedMetric {
        case "Temperature": return .red
        case "Humidity":    return .blue
        case "Wind":        return .green
        default:            return .blue
        }
    }
    
    // MARK: - Subviews for Cleanliness
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Weather Details")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color(white: 0.3))
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 16))
                    .foregroundColor(Color(white: 0.5))
            }
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(white: 0.4))
                    .frame(width: 44, height: 44)
                    .background(Circle().stroke(Color(white: 0.5).opacity(0.3), lineWidth: 1))
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 60)
        .padding(.bottom, 30)
    }
    
    private var metricSelectorLabel: some View {
        HStack(spacing: 8) {
            Image(systemName: selectedMetric == "Temperature" ? "thermometer.medium" : (selectedMetric == "Humidity" ? "humidity" : "wind"))
                .foregroundColor(chartColor.opacity(0.7))
            Text(selectedMetric)
                .foregroundColor(Color(white: 0.4))
            Image(systemName: "chevron.down")
                .font(.system(size: 12))
                .foregroundColor(Color(white: 0.4))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(white: 0.7), lineWidth: 1)
        )
    }
    
    private var descriptionView: some View {
        Text(weather.description.capitalized)
            .font(.system(size: 14))
            .foregroundColor(Color(white: 0.5))
            .lineSpacing(4)
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(chartColor.opacity(0.05))
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
    }
}


#Preview {
    DetailView(weather: .previewSample)
}
