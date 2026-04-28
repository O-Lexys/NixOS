{
  lib,
  stdenv,
  fetchgit,
  cmake,
  qt6,
  kdePackages,
  wrapQtAppsHook ? qt6.wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "qt6ct-kde";
  version = "0.9-unstable";

  src = fetchgit {
    url = "https://www.opencode.net/trialuser/qt6ct.git";
    # You may need to update this hash after first build attempt
    # Run: nix-prefetch-git https://www.opencode.net/trialuser/qt6ct.git
    hash = "sha256-x9jLoh3gAsJuSZXnIimUsxZaobiNYYB1UIAwy0HqDp4=";
  };

  patches = [
    ./qt6ct.patch
  ];

  nativeBuildInputs = [
    cmake
    qt6.qttools # for linguist tools
    wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative # for QuickControls2

    # KDE Frameworks 6 dependencies added by the patch
    kdePackages.kconfig
    kdePackages.kcolorscheme
    kdePackages.kiconthemes
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DPLUGINDIR=${placeholder "out"}/${qt6.qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "Qt6 Configuration Tool with KDE Framework integration";
    homepage = "https://www.opencode.net/trialuser/qt6ct";
    license = licenses.bsd2;
    platforms = platforms.linux;
  };
}
