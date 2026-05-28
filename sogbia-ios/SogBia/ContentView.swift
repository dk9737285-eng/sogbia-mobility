import SwiftUI

struct ContentView: View {
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            // Dark base background color matching SogBia Dark Mode
            Color(hex: "0A0A0B")
                .ignoresSafeArea()
            
            // Custom WebView loading the web application
            WebView(url: URL(string: "https://sogapp.xo.je")!, isLoading: $isLoading)
                .ignoresSafeArea(edges: .bottom) // Allows beautiful edge-to-edge navigation rendering
            
            // Premium Launch Screen / Spinner Overlay
            if isLoading {
                ZStack {
                    Color(hex: "0A0A0B")
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Spacer()
                        
                        // Elegant branding icon
                        ZStack {
                            Circle()
                                .fill(Color(hex: "9E1B1F").opacity(0.1))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: "9E1B1F").opacity(0.2), lineWidth: 2)
                                )
                            
                            Image(systemName: "car.fill")
                                .font(.system(size: 44, weight: .light))
                                .foregroundColor(Color(hex: "9E1B1F")) // SogBia Brand Crimson
                        }
                        .shadow(color: Color(hex: "9E1B1F").opacity(0.2), radius: 20, x: 0, y: 10)
                        
                        Text("SogBia")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(3)
                        
                        Text("Excellence en Mobilité Urbaine")
                            .font(.system(size: 13, weight: .medium, design: .default))
                            .foregroundColor(Color(hex: "C5A028")) // SogBia Brand Gold
                            .tracking(1.5)
                        
                        Spacer()
                        
                        // Custom Circular Loader
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "C5A028")))
                            .scaleEffect(1.4)
                            .padding(.bottom, 60)
                    }
                }
                .transition(.opacity.animation(.easeInOut(duration: 0.6)))
            }
        }
    }
}

// Hex Color support helper for SwiftUI
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 1)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
