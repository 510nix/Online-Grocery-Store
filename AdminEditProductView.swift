import SwiftUI

struct AdminEditProductView: View {
    
    let product: Product
    let onSave: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String
    @State private var category: String
    @State private var price: String
    @State private var description: String
    @State private var imageURL: String
    @State private var unit: String
    @State private var isAvailable: Bool
    @State private var isSaving = false
    @State private var stock: String
    
    let units = ["piece", "kg", "pack", "litre", "dozen"]
    
    init(product: Product, onSave: @escaping () -> Void) {
        self.product = product
        self.onSave = onSave
        _name = State(initialValue: product.name)
        _category = State(initialValue: product.category)
        _price = State(initialValue: String(product.price))
        _description = State(initialValue: product.description)
        _imageURL = State(initialValue: product.imageURL)
        _unit = State(initialValue: product.unit)
        _isAvailable = State(initialValue: product.isAvailable)
        _stock = State(initialValue: String(product.stock))
    }
    
    var body: some View {
        Form {
            Section(header: Text("Product Info")) {
                TextField("Name", text: $name)
                TextField("Category", text: $category)
                TextField("Price", text: $price)
                    .keyboardType(.decimalPad)
                TextField("Description", text: $description)
                TextField("Stock Quantity", text: $stock)
                    .keyboardType(.numberPad)
            }
            
            Section(header: Text("Image")) {
                TextField("Image URL", text: $imageURL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if !imageURL.isEmpty {
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                                 .scaledToFit()
                        case .failure:
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                }
            }
            
            Section(header: Text("Unit")) {
                Picker("Unit", selection: $unit) {
                    ForEach(units, id: \.self) { u in
                        Text(u).tag(u)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("Availability")) {
                Toggle("In Stock", isOn: $isAvailable)
                    .tint(.green)
            }
            
            Section {
                Button {
                    updateProduct()
                } label: {
                    if isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Save Changes")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Edit Product")
    }
    
    func updateProduct() {
        guard let priceDouble = Double(price) else {
            // 💡 Tip: You might want to set an errorMessage here
            // like you did in saveProduct(), otherwise it fails silently!
            return
        }
        
        let stockInt = Int(stock) ?? 0
        isSaving = true
        
        let updated = Product(
            id: product.id,
            name: name,
            category: category.lowercased(),
            price: priceDouble,
            imageURL: imageURL,
            description: description,
            unit: unit,
            isAvailable: stockInt > 0,
            stock: stockInt
        )
        
        FirebaseService.shared.saveProduct(product: updated) { success in
            isSaving = false
            if success {
                onSave()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
