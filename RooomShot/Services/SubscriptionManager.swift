import Combine
import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var isSubscribed = false
    @Published private(set) var isLoading = false
    @Published private(set) var isPurchasing = false
    @Published private(set) var errorMessage: String?

    private var hasPrepared = false
    private var updatesTask: Task<Void, Never>?

    var monthlyProduct: Product? {
        products.first { $0.id == SubscriptionPlan.monthlyProductID }
    }

    var displayedMonthlyPrice: String {
        monthlyProduct?.displayPrice ?? SubscriptionPlan.fallbackMonthlyPrice
    }

    init() {
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard !Task.isCancelled else { return }
                guard case .verified(let transaction) = result else { continue }
                await transaction.finish()
                await self?.refreshEntitlementStatus()
            }
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func prepare() async {
        guard !hasPrepared else { return }
        hasPrepared = true
        isLoading = true
        defer { isLoading = false }

        await refreshEntitlementStatus()
        await loadProducts()
    }

    func reloadProducts() async {
        isLoading = true
        defer { isLoading = false }
        await loadProducts()
    }

    @discardableResult
    func purchaseMonthly() async -> Bool {
        guard let product = monthlyProduct else {
            errorMessage = NSLocalizedString("subscription.error.unavailable", comment: "")
            return false
        }

        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    errorMessage = NSLocalizedString("subscription.error.verification", comment: "")
                    return false
                }
                await transaction.finish()
                await refreshEntitlementStatus()
                return isSubscribed
            case .pending:
                errorMessage = NSLocalizedString("subscription.error.pending", comment: "")
                return false
            case .userCancelled:
                return false
            @unknown default:
                errorMessage = NSLocalizedString("subscription.error.unknown", comment: "")
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await refreshEntitlementStatus()
            if !isSubscribed {
                errorMessage = NSLocalizedString("subscription.restore.none", comment: "")
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }

    private func loadProducts() async {
        do {
            products = try await Product.products(for: SubscriptionPlan.productIDs)
                .sorted { $0.price < $1.price }
            if products.isEmpty {
                errorMessage = NSLocalizedString("subscription.error.unavailable", comment: "")
            } else {
                errorMessage = nil
            }
        } catch {
            products = []
            errorMessage = error.localizedDescription
        }
    }

    private func refreshEntitlementStatus() async {
        var hasActiveSubscription = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard SubscriptionPlan.productIDs.contains(transaction.productID) else { continue }
            guard transaction.revocationDate == nil else { continue }
            hasActiveSubscription = true
            break
        }

        isSubscribed = hasActiveSubscription
    }
}
