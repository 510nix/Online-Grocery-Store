import SwiftUI
import FirebaseAuth

struct ProductCard: View {
    let product: Product
    @EnvironmentObject var cartVM: CartViewModel
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationLink(destination:
            ProductDetailView(product: product)
                .environmentObject(cartVM)
                .environmentObject(authService)
        ) {
            VStack(alignment: .leading, spacing: 0) {
                
                // Image
                GeometryReader { geo in
                    AsyncImage(url: URL(string: product.imageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: 120)
                                .clipped()
                        default:
                            Color(.systemGray5)
                                .frame(width: geo.size.width, height: 120)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                }
                .frame(height: 120)
                .clipped()
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            if !product.isAvailable {
                                Text("Out of Stock")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.red)
                                    .cornerRadius(6)
                                    .padding(6)
                            } else if product.stock <= 5 && product.stock > 0 {
                                Text("Only \(product.stock) left")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.orange)
                                    .cornerRadius(6)
                                    .padding(6)
                            }
                        }
                        Spacer()
                    }
                )
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.category.capitalized)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    Text(product.name)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity,
                               minHeight: 30, maxHeight: 30,
                               alignment: .topLeading)
                    
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("$\(String(format: "%.2f", product.price))")
                                .font(.caption)
                                .fontWeight(.heavy)
                                .foregroundColor(.green)
                            Text("per \(product.unit)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button {
                            if Auth.auth().currentUser != nil {
                                cartVM.addToCart(product: product)
                            }
                        } label: {
                            ZStack {
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.0, green: 0.8, blue: 0.4),
                                        Color(red: 0.0, green: 0.6, blue: 0.9)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .frame(width: 30, height: 30)
                                .cornerRadius(8)
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }
                        .buttonStyle(.borderless)
                        .disabled(!product.isAvailable)
                        .opacity(product.isAvailable ? 1.0 : 0.4)
                    }
                }
                .padding(8)
                .frame(height: 80)
                .background(Color.white)
            }
            .frame(height: 200)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .clipped()
        }
        .buttonStyle(PlainButtonStyle())
    }
}
