import SwiftUI
import Combine

struct TemperatureChart: View {
    let hourlyData: [HourlyTemp]
    let color: Color
    @AppStorage("temp_unit") private var unit: String = "C"
    
    var body: some View {
        // We use GeometryReader to get the frame size for our custom Shape
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            // Calculate min, max, and range for the Y-axis scaling
            let temps = hourlyData.map { $0.temperature }
            let minTemp = temps.min() ?? 0
            let maxTemp = temps.max() ?? 100
            let range = max(maxTemp - minTemp, 1.0) // Avoid division by zero
            
            ZStack(alignment: .bottom) {
                // 1. Draw the Gradient Fill
                ChartPath(data: temps, width: width, height: height, minTemp: minTemp, range: range)
                    .fill(
                        LinearGradient(colors: [.blue.opacity(0.3), .blue.opacity(0.01)],
                                       startPoint: .top, endPoint: .bottom)
                    )
                
                // 2. Draw the actual Line
                ChartPath(data: temps, width: width, height: height, minTemp: minTemp, range: range)
                    .stroke(Color.blue, lineWidth: 3)
                
                // 3. The Hour Labels (moved inside ZStack correctly)
                HStack(spacing: 0) {
                    ForEach(hourlyData) { data in
                        Text(data.hour)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
                .offset(y: 30) // Keeps labels below the chart
            }
        }
        // Add padding to account for the label offset
        .padding(.bottom, 30)
    }
}

//MARK: chartpath

struct ChartPath: Shape {
    let data: [Double]
    let width: CGFloat
    let height: CGFloat
    let minTemp: Double
    let range: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard data.count > 1 else { return path }
        
        let stepX = width / CGFloat(data.count - 1)
        
        for (index, temp) in data.enumerated() {
            let x = CGFloat(index) * stepX
            // Y is inverted in SwiftUI (0 is top)
            let y = height - CGFloat((temp - minTemp) / range) * height
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }
}
#Preview {
    TemperatureChart(
        hourlyData: [
            HourlyTemp(hour: "12PM", temperature: 25),
            HourlyTemp(hour: "3PM", temperature: 28),
            HourlyTemp(hour: "6PM", temperature: 22)
        ],
        color: .blue // <--- Add this
    )
    .frame(height: 200)
    .padding()
}
