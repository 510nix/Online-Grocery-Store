import SwiftUI

struct AdminProductsView: View {
    
    @State private var products: [Product] = []
    @State private var isLoading = true
    @State private var showAddProduct = false
    @State private var showDeleteAlert = false
    @State private var productToDelete: Product? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    Spacer()
                    ProgressView("Loading products...")
                    Spacer()
                } else if products.isEmpty {
                    Spacer()
                    Image(systemName: "cube.box")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No products yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                    Text("Tap + to add your first product")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List {
                        ForEach(products) { product in
                            NavigationLink(destination:
                                AdminEditProductView(product: product) {
                                    loadProducts()
                                }
                            ) {
                                HStack(spacing: 12) {
                                    AsyncImage(url: URL(string: product.imageURL)) { img in
                                        img.resizable().scaledToFill()
                                    } placeholder: {
                                        Color(.systemGray5)
                                            .overlay(
                                                Image(systemName: "photo")
                                                    .foregroundColor(.gray)
                                            )
                                    }
                                    .frame(width: 55, height: 55)
                                    .clipped()
                                    .cornerRadius(8)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(product.name)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        Text(product.category.capitalized)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(product.isAvailable ? Color.green : Color.red)
                                                .frame(width: 6, height: 6)
                                            Text(product.isAvailable
                                                 ? "In Stock (\(product.stock))"
                                                 : "Out of Stock")
                                                .font(.caption2)
                                                .foregroundColor(product.isAvailable ? .green : .red)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text("$\(String(format: "%.2f", product.price))")
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { i in
                                productToDelete = products[i]
                                showDeleteAlert = true
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Products")
            .navigationBarItems(trailing:
                HStack {
                    EditButton()
                        .foregroundColor(.green)
                    Button {
                        showAddProduct = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }
            )
            .sheet(isPresented: $showAddProduct, onDismiss: loadProducts) {
                AdminAddProductView()
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Product"),
                    message: Text("Are you sure you want to delete '\(productToDelete?.name ?? "")'? This cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let product = productToDelete {
                            deleteProduct(product: product)
                        }
                    },
                    secondaryButton: .cancel()
                )
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
    
    func deleteProduct(product: Product) {
        FirebaseService.shared.deleteProduct(productId: product.id) { success in
            if success {
                loadProducts()
            }
        }
    }
}
