import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var cartVM: CartViewModel
    @State private var products: [Product] = []
    @State private var recommendations: [Product] = []
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var categories: [String] = ["All"]
    
    let gradientColors: [Color] = [
        Color(red: 0.0, green: 0.8, blue: 0.4),
        Color(red: 0.0, green: 0.6, blue: 0.9)
    ]
    
    var filteredProducts: [Product] {
        var list = products
        if selectedCategory != "All" {
            list = list.filter {
                $0.category.lowercased() == selectedCategory.lowercased()
            }
        }
        if !searchText.isEmpty {
            list = list.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        return list
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color(.systemGray6).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // Header
                    ZStack {
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea(edges: .top)
                        
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Hello! 👋")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                    Text("FreshCart")
                                        .font(.title)
                                        .fontWeight(.heavy)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                
                                // Orders button
                                NavigationLink(destination: OrderHistoryView()) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.2))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "clock.arrow.2.circlepath")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16))
                                    }
                                }
                                
                                // Cart button
                                NavigationLink(destination:
                                    CartView()
                                        .environmentObject(cartVM)
                                        .environmentObject(authService)
                                ) {
                                    ZStack(alignment: .topTrailing) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "cart.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 16))
                                        }
                                        if cartVM.totalItems > 0 {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.red)
                                                    .frame(width: 18, height: 18)
                                                Text(String(format: "%d", cartVM.totalItems))
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                            .offset(x: 4, y: -4)
                                        }
                                    }
                                }
                                
                                // Logout
                                Button {
                                    authService.logout()
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.2))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "arrow.right.square")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16))
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Search bar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                TextField("Search fresh products...", text: $searchText)
                                    .autocapitalization(.none)
                                if !searchText.isEmpty {
                                    Button {
                                        searchText = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(14)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                        }
                    }
                    .frame(height: 160)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            
                            // Categories
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(categories, id: \.self) { cat in
                                        Button {
                                            selectedCategory = cat
                                            loadProducts(category: cat)
                                        } label: {
                                            Text(cat.capitalized)
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(
                                                    selectedCategory == cat
                                                    ? LinearGradient(
                                                        colors: gradientColors,
                                                        startPoint: .leading,
                                                        endPoint: .trailing)
                                                    : LinearGradient(
                                                        colors: [Color.white, Color.white],
                                                        startPoint: .leading,
                                                        endPoint: .trailing)
                                                )
                                                .foregroundColor(selectedCategory == cat ? .white : .black)
                                                .cornerRadius(20)
                                                .shadow(
                                                    color: selectedCategory == cat
                                                    ? Color.green.opacity(0.3)
                                                    : Color.black.opacity(0.05),
                                                    radius: 4, x: 0, y: 2)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                            }
                            
                            // Recommendations
                            if !recommendations.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.orange)
                                        Text("Recommended For You")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(recommendations) { product in
                                                NavigationLink(destination:
                                                    ProductDetailView(product: product)
                                                        .environmentObject(cartVM)
                                                        .environmentObject(authService)
                                                ) {
                                                    VStack(alignment: .leading, spacing: 6) {
                                                        GeometryReader { geo in
                                                            AsyncImage(url: URL(string: product.imageURL)) { phase in
                                                                switch phase {
                                                                case .success(let img):
                                                                    img.resizable()
                                                                        .scaledToFill()
                                                                        .frame(width: geo.size.width, height: 90)
                                                                        .clipped()
                                                                default:
                                                                    Color(.systemGray5)
                                                                        .frame(width: geo.size.width, height: 90)
                                                                }
                                                            }
                                                        }
                                                        .frame(height: 90)
                                                        .cornerRadius(10)
                                                        
                                                        Text(product.name)
                                                            .font(.caption)
                                                            .fontWeight(.semibold)
                                                            .foregroundColor(.black)
                                                            .lineLimit(1)
                                                            .padding(.horizontal, 6)
                                                        
                                                        Text("$\(String(format: "%.2f", product.price))")
                                                            .font(.caption)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.green)
                                                            .padding(.horizontal, 6)
                                                            .padding(.bottom, 6)
                                                    }
                                                    .frame(width: 120)
                                                    .background(Color.white)
                                                    .cornerRadius(12)
                                                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.bottom, 4)
                                    }
                                }
                                .padding(.bottom, 16)
                            }
                            
                            // Products section header
                            HStack {
                                Text("All Products")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Spacer()
                                Text("\(filteredProducts.count) items")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
                            
                            // Products grid
                            if isLoading {
                                VStack {
                                    Spacer().frame(height: 60)
                                    ProgressView("Loading fresh products...")
                                        .tint(.green)
                                    Spacer()
                                }
                            } else if filteredProducts.isEmpty {
                                VStack(spacing: 12) {
                                    Spacer().frame(height: 40)
                                    Image(systemName: "cart.badge.questionmark")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                    Text("No products found")
                                        .foregroundColor(.gray)
                                }
                            } else {
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 12),
                                    GridItem(.flexible(), spacing: 12)
                                ], spacing: 16) {
                                    ForEach(filteredProducts) { product in
                                        ProductCard(product: product)
                                            .environmentObject(cartVM)
                                            .environmentObject(authService)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadProducts(category: "All")
                loadCategories()
                RecommendationService.shared.getHomeRecommendations { products in
                    self.recommendations = products
                }
            }
        }
    }
    
    func loadProducts(category: String) {
        isLoading = true
        if category == "All" {
            APIService.shared.fetchProducts { fetched in
                self.products = fetched
                self.isLoading = false
            }
        } else {
            APIService.shared.fetchByCategory(category) { fetched in
                self.products = fetched
                self.isLoading = false
            }
        }
    }
    
    func loadCategories() {
        APIService.shared.fetchProducts { products in
            let cats = Set(products.map { $0.category })
            self.categories = ["All"] + Array(cats).sorted()
        }
    }
}
