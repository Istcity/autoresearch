import Foundation
import StoreKit
import Observation

@Observable
@MainActor
final class PurchaseManager {
    static let proProductID = "stillway.pro.lifetime.499"

    var isPro = false
    var product: Product?
    var lastError: String?
    var isLoading = false

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let products = try await Product.products(for: [Self.proProductID])
            product = products.first
            await refreshEntitlements()
        } catch {
            lastError = error.localizedDescription
            isPro = UserDefaults.standard.bool(forKey: "stillway.isPro.debug")
        }
    }

    func purchase() async {
        guard let product else { return }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified = verification {
                    isPro = true
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            lastError = error.localizedDescription
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    func unlockForPreview() {
        isPro = true
        UserDefaults.standard.set(true, forKey: "stillway.isPro.debug")
    }

    private func refreshEntitlements() async {
        for await entitlement in Transaction.currentEntitlements {
            if case .verified(let transaction) = entitlement, transaction.productID == Self.proProductID {
                isPro = true
                return
            }
        }
    }
}
