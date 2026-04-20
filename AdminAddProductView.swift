import SwiftUI

struct AdminAddProductView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var category = ""
    @State private var price = ""
    @State private var description = ""
    @State private var imageURL = ""
    @State private var unit = "piece"
    @State private var isSaving = false
    @State private var errorMessage = ""
    @State private var stock = ""
    let units = ["piece", "kg", "pack", "litre", "dozen"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Info")) {
                    TextField("Product Name", text: $name)
                    TextField("Category (e.g. groceries)", text: $category)
                    TextField("Price (e.g. 4.99)", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Description", text: $description)
                    TextField("Stock Quantity (e.g. 50)", text: $stock).keyboardType(.numberPad)
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
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.red)
                            case .empty:
                                ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
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
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button {
                        saveProduct()
                    } label: {
                        if isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Add Product")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .background(name.isEmpty || price.isEmpty ? Color.gray : Color.green)
                                .cornerRadius(10)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .disabled(name.isEmpty || price.isEmpty || isSaving)
                }
            }
            .navigationTitle("Add Product")
            .navigationBarItems(leading:
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    func saveProduct() {
        guard let priceDouble = Double(price) else {
            errorMessage = "Invalid price"
            return
        }
        
        guard !stock.isEmpty, let stockInt = Int(stock) else {
            errorMessage = "Please enter valid stock quantity"
            return
        }
        
        isSaving = true
        
        let productId = UUID().uuidString
        let product = Product(
            id: productId,
            name: name,
            category: category.lowercased(),
            price: priceDouble,
            imageURL: imageURL,
            description: description,
            unit: unit,
            isAvailable: stockInt > 0,
            stock: stockInt
        )
        
        print("DEBUG saving product with stock: \(stockInt)")
        
        FirebaseService.shared.saveProduct(product: product) { success in
            self.isSaving = false
            if success {
                self.presentationMode.wrappedValue.dismiss()
            } else {
                self.errorMessage = "Failed to save. Try again."
            }
        }
    }
}
