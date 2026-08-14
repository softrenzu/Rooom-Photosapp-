import SwiftUI

struct SubscriptionPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subscriptions: SubscriptionManager

    var body: some View {
        NavigationStack {
            ZStack {
                BrandBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        Image(systemName: "icloud.and.arrow.up.fill")
                            .font(.system(size: 58, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 116, height: 116)
                            .background(Color.accentColor.gradient, in: RoundedRectangle(cornerRadius: 28))
                            .shadow(color: .cyan.opacity(0.35), radius: 24, y: 12)

                        VStack(spacing: 8) {
                            Text("subscription.title")
                                .font(.largeTitle.bold())
                            Text("subscription.subtitle")
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white.opacity(0.75))
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                feature("subscription.feature.upload", icon: "camera.fill")
                                feature("subscription.feature.offline", icon: "arrow.triangle.2.circlepath")
                                feature("subscription.feature.quality", icon: "photo.fill.on.rectangle.fill")
                            }
                        }

                        VStack(spacing: 14) {
                            Text(String(format: NSLocalizedString("subscription.priceFormat", comment: ""), subscriptions.displayedMonthlyPrice))
                                .font(.title2.bold())

                            Button {
                                Task {
                                    if await subscriptions.purchaseMonthly() {
                                        dismiss()
                                    }
                                }
                            } label: {
                                HStack {
                                    if subscriptions.isPurchasing {
                                        ProgressView().tint(.white)
                                    }
                                    Text("subscription.purchase")
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 15))
                            }
                            .buttonStyle(.plain)
                            .disabled(subscriptions.isPurchasing || subscriptions.monthlyProduct == nil)

                            if subscriptions.monthlyProduct == nil {
                                Button("subscription.retry") {
                                    Task { await subscriptions.reloadProducts() }
                                }
                                .disabled(subscriptions.isLoading)
                            }

                            Button("subscription.restore") {
                                Task {
                                    await subscriptions.restorePurchases()
                                    if subscriptions.isSubscribed { dismiss() }
                                }
                            }
                            .disabled(subscriptions.isLoading || subscriptions.isPurchasing)

                            if let errorMessage = subscriptions.errorMessage {
                                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                                    .font(.footnote)
                                    .foregroundStyle(.orange)
                                    .multilineTextAlignment(.center)
                            }
                        }

                        Text("subscription.renewalDisclosure")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.68))
                            .multilineTextAlignment(.center)

                        HStack(spacing: 20) {
                            Link("link.terms", destination: SubscriptionPlan.termsURL)
                            Link("link.privacy", destination: SubscriptionPlan.privacyURL)
                        }
                        .font(.footnote)
                    }
                    .padding(22)
                }
            }
            .foregroundStyle(.white)
            .navigationTitle("subscription.navigationTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.close") { dismiss() }
                }
            }
        }
        .onDisappear { subscriptions.clearError() }
        .task { await subscriptions.prepare() }
    }

    private func feature(_ title: LocalizedStringKey, icon: String) -> some View {
        Label {
            Text(title).font(.headline)
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(.cyan)
                .frame(width: 30)
        }
    }
}
