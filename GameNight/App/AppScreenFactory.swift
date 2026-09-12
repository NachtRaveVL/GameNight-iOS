// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

/// The composition layer is the only layer that knows views and concrete wiring.
/// Constructors perform no I/O. Each destination view retains its model with @State.
@MainActor
struct AppScreenFactory {
    let dependencies: AppDependencies
    let router: AppRouter
    let theme: ThemeState

    @ViewBuilder
    func makeRoute(_ route: AppRoute) -> some View {
        switch route {
        case .gameCatalog(let collection):
            GameCatalogView(viewModel: GameCatalogViewModel(
                router: router,
                catalog: dependencies.catalog,
                collection: collection,
                eras: dependencies.computerEras
            ))
        case .gameDetail(let context):
            GameDetailView(viewModel: GameDetailViewModel(
                router: router,
                catalog: dependencies.catalog,
                artwork: dependencies.artwork,
                library: dependencies.library,
                context: context
            ))
        case .recommendationTuning(let gameID):
            RecommendationTuningView(viewModel: RecommendationTuningViewModel(
                router: router,
                recommendations: dependencies.recommendations,
                library: dependencies.library,
                gameID: gameID
            ))
        case .computerEras:
            ComputerErasView(viewModel: ComputerErasViewModel(router: router))
        case .appearance:
            AppearanceView(viewModel: AppearanceViewModel(router: router, theme: theme))
        case .shortlist:
            ShortlistView(viewModel: ShortlistViewModel(router: router, library: dependencies.library))
        case .tonight:
            TonightView(viewModel: TonightViewModel(
                router: router,
                library: dependencies.library,
                recommendations: dependencies.recommendations
            ))
        case .shelves:
            ShelvesView(viewModel: ShelvesViewModel(router: router, library: dependencies.library))
        case .gameNote(let releaseID):
            GameNoteView(viewModel: GameNoteViewModel(
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
            APIKeyView(viewModel: APIKeyViewModel(
                credentials: dependencies.credentials, connection: dependencies.connection
            ))
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
