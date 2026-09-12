// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

/// The composition layer is the only layer that knows views and concrete wiring.
/// Constructors perform no I/O. Each destination view retains its model with @State.
@MainActor
struct AppScreenFactory {
    let dependencies: AppDependencies
    let router: AppRouter

    @ViewBuilder
    func makeRoute(_ route: AppRoute) -> some View {
        switch route {
        case .consoleCatalog(let platformID):
            ConsoleCatalogView(viewModel: ConsoleCatalogViewModel(
                router: router,
                catalog: dependencies.catalog,
                platformID: platformID
            ))
        case .gameDetail(let releaseID):
            GameDetailView(viewModel: GameDetailViewModel(
                router: router,
                catalog: dependencies.catalog,
                artwork: dependencies.artwork,
                library: dependencies.library,
                releaseID: releaseID
            ))
        case .recommendationTuning(let gameID):
            RecommendationTuningView(viewModel: RecommendationTuningViewModel(
                router: router,
                recommendations: dependencies.recommendations,
                library: dependencies.library,
                gameID: gameID
            ))
        case .tonight:
            TonightView(viewModel: TonightViewModel(
                router: router,
                library: dependencies.library,
                recommendations: dependencies.recommendations
            ))
        case .shelves:
            ShelvesView(viewModel: ShelvesViewModel(router: router, library: dependencies.library))
        case .resumeNote(let releaseID):
            ResumeNoteView(viewModel: ResumeNoteViewModel(
                router: router,
                library: dependencies.library,
                releaseID: releaseID
            ))
        case .gameNight:
            GameNightView(viewModel: GameNightViewModel(
                router: router,
                catalog: dependencies.catalog,
                library: dependencies.library
            ))
        case .consoleSelection:
            ConsoleSelectionView(viewModel: ConsoleSelectionViewModel(
                router: router,
                catalog: dependencies.catalog,
                library: dependencies.library
            ))
        case .tasteSetup:
            TasteSetupView(viewModel: TasteSetupViewModel(
                router: router,
                catalog: dependencies.catalog,
                library: dependencies.library
            ))
        case .apiKey:
            APIKeyView(viewModel: APIKeyViewModel(router: router, credentials: dependencies.credentials))
        case .artworkSources:
            ArtworkSourcesView(viewModel: ArtworkSourcesViewModel(router: router, artwork: dependencies.artwork))
        case .dataTransfer:
            DataTransferView(viewModel: DataTransferViewModel(router: router, library: dependencies.library))
        case .hiddenGames:
            HiddenGamesView(viewModel: HiddenGamesViewModel(router: router, library: dependencies.library))
        }
    }

    @ViewBuilder
    func makeSheet(_ sheet: AppSheet) -> some View {
        switch sheet {
        case .onboarding:
            OnboardingView(viewModel: OnboardingViewModel(router: router, library: dependencies.library))
        case .artwork(let releaseID):
            ArtworkGalleryView(viewModel: ArtworkGalleryViewModel(
                router: router,
                artwork: dependencies.artwork,
                releaseID: releaseID
            ))
        }
    }
}
