import SwiftUI
import FirebaseAuth

struct ProductDetailView: View {
    
    let product: Product
    @EnvironmentObject var cartVM: CartViewModel
    @EnvironmentObject var authService: AuthService
    @State private var quantity = 1
    @State private var showLoginAlert = false
    @State private var recommendations: [Product] = []
    @State private var nutritionInfo: NutritionInfo? = nil
    @State private var isLoadingNutrition = false
    @State private var currentStock: Int = 0
    @State private var currentlyAvailable: Bool = true
    @Environment(\.presentationMode) var presentationMode
    
    // Computed property — avoids EnvironmentObject closure error
    private var userIsLoggedIn: Bool {
        Auth.auth().currentUser != nil
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                // Product Image
                AsyncImage(url: URL(string: product.imageURL)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Color(.systemGray5)
                        .overlay(ProgressView())
                }
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .background(Color(.systemGray6))
                
                VStack(alignment: .leading, spacing: 14) {
                    
                    // Group 1 — Product Header
                    Group {
                        Text(product.category.uppercased())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        
                        Text(product.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("$\(String(format: "%.2f", product.price))")
                            .font(.title)
                            .fontWeight(.heavy)
                            .foregroundColor(.green)
                        
                        Text("Per \(product.unit)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 8) {
                            Circle()
                                .fill(currentlyAvailable
                                      ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            if currentlyAvailable {
                                if currentStock <= 5 && currentStock > 0 {
                                    Text("Only \(currentStock) left!")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                } else {
                                    Text("In Stock (\(currentStock) available)")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            } else {
                                Text("Out of Stock")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        Divider()
                    }
                    
                    // Group 2 — Description + Nutrition
                    Group {
                        Text("Description")
                            .font(.headline)
                        
                        Text(product.description.isEmpty
                             ? "No description available."
                             : product.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "heart.text.square.fill")
                                    .foregroundColor(.green)
                                Text("Nutrition Info")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text("(per 100g)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            if isLoadingNutrition {
                                HStack {
                                    ProgressView()
                                    Text("Loading nutrition data...")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            } else if let nutrition = nutritionInfo {
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 12) {
                                    NutritionBadge(
                                        label: "Calories",
                                        value: String(format: "%.0f",
                                                      nutrition.calories),
                                        unit: "kcal",
                                        color: .orange)
                                    NutritionBadge(
                                        label: "Protein",
                                        value: String(format: "%.1f",
                                                      nutrition.protein),
                                        unit: "g",
                                        color: .blue)
                                    NutritionBadge(
                                        label: "Fat",
                                        value: String(format: "%.1f",
                                                      nutrition.fat),
                                        unit: "g",
                                        color: .yellow)
                                    NutritionBadge(
                                        label: "Carbs",
                                        value: String(format: "%.1f",
                                                      nutrition.carbs),
                                        unit: "g",
                                        color: .purple)
                                    NutritionBadge(
                                        label: "Fiber",
                                        value: String(format: "%.1f",
                                                      nutrition.fiber),
                                        unit: "g",
                                        color: .green)
                                    NutritionBadge(
                                        label: "Sugar",
                                        value: String(format: "%.1f",
                                                      nutrition.sugar),
                                        unit: "g",
                                        color: .red)
                                }
                            } else {
                                Text("Nutrition info not available")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Divider()
                    }
                    
                    // Group 3 — Quantity + Cart Button
                    Group {
                        HStack {
                            Text("Quantity")
                                .font(.headline)
                            Spacer()
                            HStack(spacing: 16) {
                                Button {
                                    if quantity > 1 { quantity -= 1 }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                }
                                
                                Text(String(format: "%d", quantity))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .frame(width: 30)
                                
                                Button {
                                    if quantity < currentStock {
                                        quantity += 1
                                    }
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(
                                            quantity >= currentStock
                                            ? .gray : .green)
                                }
                                .disabled(quantity >= currentStock)
                            }
                        }
                        
                        // Add to Cart Button
                        Button {
                            if !userIsLoggedIn {
                                showLoginAlert = true
                            } else {
                                cartVM.addToCart(product: product,
                                                quantity: quantity)
                                presentationMode.wrappedValue.dismiss()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "cart.badge.plus")
                                Text("Add to Cart — $\(String(format: "%.2f", product.price * Double(quantity)))")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(currentlyAvailable
                                        ? Color.green : Color.gray)
                            .cornerRadius(14)
                        }
                        .disabled(!currentlyAvailable)
                    }
                }
                .padding()
                
                // Recommendations Section
                if !recommendations.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("You May Also Like")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(recommendations) { rec in
                                    NavigationLink(destination:
                                        ProductDetailView(product: rec)
                                            .environmentObject(cartVM)
                                            .environmentObject(authService)
                                    ) {
                                        VStack(alignment: .leading,
                                               spacing: 6) {
                                            AsyncImage(url: URL(
                                                string: rec.imageURL)) { img in
                                                img.resizable()
                                                    .scaledToFill()
                                            } placeholder: {
                                                Color(.systemGray5)
                                            }
                                            .frame(width: 120, height: 100)
                                            .clipped()
                                            .cornerRadius(10)
                                            
                                            Text(rec.name)
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .lineLimit(2)
                                                .frame(width: 120,
                                                       alignment: .leading)
                                                .foregroundColor(.primary)
                                            
                                            Text("$\(String(format: "%.2f", rec.price))")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.green)
                                        }
                                        .frame(width: 120)
                                        .padding(8)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(12)
                                        .shadow(color: .black.opacity(0.07),
                                                radius: 4, x: 0, y: 2)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            currentStock = product.stock
            currentlyAvailable = product.isAvailable
            refreshStock()
            
            RecommendationService.shared.trackView(product: product)
            RecommendationService.shared.getRecommendations(
                currentProductId: product.id) { products in
                self.recommendations = products
            }
            
            isLoadingNutrition = true
            NutritionService.shared.fetchNutrition(
                for: product.name) { info in
                self.nutritionInfo = info
                self.isLoadingNutrition = false
            }
        }
        .alert(isPresented: $showLoginAlert) {
            Alert(
                title: Text("Login Required"),
                message: Text("Please login to add items to cart"),
                primaryButton: .default(Text("Login")) {},
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: - Refresh Live Stock from Firestore
    func refreshStock() {
        FirebaseService.shared.db
            .collection("products")
            .whereField("name", isEqualTo: product.name)
            .getDocuments { snapshot, error in
                guard let doc = snapshot?.documents.first else { return }
                let stock: Int
                if let s = doc.data()["stock"] as? Int {
                    stock = s
                } else if let s = doc.data()["stock"] as? Double {
                    stock = Int(s)
                } else {
                    stock = 0
                }
                DispatchQueue.main.async {
                    self.currentStock = stock
                    self.currentlyAvailable = stock > 0
                }
            }
    }
}
