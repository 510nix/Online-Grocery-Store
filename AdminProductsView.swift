import SwiftUI

struct AdminProductsView: View {
    @State private var products: [Product] = []
    @State private var isLoading = true
    @State private var showAddProduct = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Vibrant Mesh Gradient Background
                LinearGradient(colors: [Color.green.opacity(0.2), Color.blue.opacity(0.1), .white],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView().tint(.green)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Product Management")
                                .font(.caption).bold().foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            LazyVStack(spacing: 20) {
                                ForEach(products) { product in
                                    NavigationLink(destination: AdminEditProductView(product: product) { loadProducts() }) {
                                        VibrantProductCard(product: product)
                                    }
                                    .buttonStyle(ScaledButtonStyle()) // Custom interaction effect
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Shop")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAddProduct = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(Color.green))
                            .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                }
            }
            .sheet(isPresented: $showAddProduct, onDismiss: loadProducts) {
                AdminAddProductView()
            }
            .onAppear { loadProducts() }
        }
    }
    
    func loadProducts() {
        isLoading = true
        FirebaseService.shared.fetchAdminProducts { fetched in
            self.products = fetched
            self.isLoading = false
        }
    }
}

struct VibrantProductCard: View {
    let product: Product
    
    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: product.imageURL)) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.2))
                    .overlay(Image(systemName: "photo"))
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(product.category.uppercased())
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.green)
                
                HStack(spacing: 4) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                    Text("\(product.stock) units in stock")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack {
                Text("$\(String(format: "%.2f", product.price))")
                    .font(.system(.subheadline, design: .rounded)).bold()
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(.ultraThinMaterial) // The "Glass" effect
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 10)
    }
}

// Button style that shrinks when tapped (Very "unique" feel)
struct ScaledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
