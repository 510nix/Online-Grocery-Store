import SwiftUI

struct AdminAddProductView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var price = ""
    @State private var stock = ""
    @State private var imageURL = ""
    @State private var category = ""
    @State private var isSaving = false
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            
            VStack {
                // Vibrant Header
                HStack {
                    Text("Add Product")
                        .font(.largeTitle).bold()
                    Spacer()
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                        .foregroundColor(.green)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Image Preview with Glow
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 140, height: 140)
                                .blur(radius: 20)
                            
                            AsyncImage(url: URL(string: imageURL)) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                Image(systemName: "plus.viewfinder").font(.largeTitle).foregroundColor(.green)
                            }
                            .frame(width: 120, height: 120)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                        }
                        .padding(.bottom, 10)
                        
                        VStack(spacing: 16) {
                            VibrantField(title: "PRODUCT NAME", text: $name, icon: "pencil")
                            VibrantField(title: "CATEGORY", text: $category, icon: "tray.full")
                            HStack {
                                VibrantField(title: "PRICE", text: $price, icon: "dollarsign", keyboard: .decimalPad)
                                VibrantField(title: "STOCK", text: $stock, icon: "shippingbox", keyboard: .numberPad)
                            }
                            VibrantField(title: "IMAGE URL", text: $imageURL, icon: "link")
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(30)
                        .padding(.horizontal)
                    }
                }
                
                Button(action: saveProduct) {
                    Text(isSaving ? "Syncing..." : "Add to Store")
                        .font(.headline).bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(name.isEmpty ? Color.gray.opacity(0.3) : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .padding()
                        .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(name.isEmpty || isSaving)
            }
        }
    }
    
    func saveProduct() {
        guard let p = Double(price), let s = Int(stock) else { return }
        isSaving = true
        let product = Product(id: UUID().uuidString, name: name, category: category.lowercased(), price: p, imageURL: imageURL, description: "", unit: "piece", isAvailable: s > 0, stock: s)
        FirebaseService.shared.saveProduct(product: product) { _ in
            isSaving = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct VibrantField: View {
    let title: String
    @Binding var text: String
    let icon: String
    var keyboard: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.system(size: 10, weight: .black)).foregroundColor(.gray)
            HStack {
                Image(systemName: icon).foregroundColor(.green)
                TextField("", text: $text).keyboardType(keyboard)
            }
            Divider()
        }
    }
}
