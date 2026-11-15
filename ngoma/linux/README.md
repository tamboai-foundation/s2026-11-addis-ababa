# NGoma — Linux (Qt 6 / QML + TModeler C++)

Projet de départ Foundation. Module QML / package : `ai.tambo.foundation.ngoma`. Charte rouge (`#E0262D`, `qml/Theme.qml`).

## Prérequis
Qt 6.8+ (Core, Quick, QuickControls2), CMake 3.16+, un compilateur C++20, git (FetchContent).

## Construire et lancer
```
cmake -S . -B build -DCMAKE_PREFIX_PATH=<chemin Qt>
cmake --build build
./build/appNGoma
```
TModeler C++ est récupéré par FetchContent (`https://github.com/TTT-GH/TModeler.git`, branche `main`, sous-dossier `cpp`), comme dans `cpp/tests/qtcreator`.

## Écrans
Splash de chargement, connexion / inscription, liste des conversations (recherche, filtres, épingler, sourdine, archiver), conversation (envoi, réponse, modification, suppression, réactions).

## Mocks (niveau ui-bridge-TModeler)
`qml/MockBridge.qml` : singleton QML (compte + messagerie, tout identifiant est accepté). Toute l'UI passe par lui.
Pour passer à TModeler : fournir un pont avec les mêmes propriétés et fonctions, adossé aux `TViewModel`.

## TModeler
- Init et modèle d'exemple : `src/models.h` / `src/models.cpp` (`Note`, `initTModeler()`).
- ViewModel QML d'exemple : `src/viewmodels.hpp` (`NoteViewModel`, enregistré dans `main.cpp` : `import models 1.0`).
- `NGOMA_DB_VERSION` : l'incrémenter repart d'une base vide.
