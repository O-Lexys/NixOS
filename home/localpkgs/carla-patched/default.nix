{ stdenv, lib, fetchFromGitHub, makeWrapper, pkg-config, which, python3
, alsa-lib, pulseaudio, jack2, liblo, file, libsndfile, fluidsynth, libX11, gtk2
, gtk3, qt5, autoPatchelfHook }:

let pythonEnv = python3.withPackages (ps: with ps; [ pyqt5 rdflib pyliblo3 ]);
in stdenv.mkDerivation rec {
  pname = "carla-patched";
  version = "v2.5.10";

  src = fetchFromGitHub {
    owner = "falkTX";
    repo = "carla";
    rev = "v2.5.10";
    hash = "sha256-21QaFCIjGjRTcJtf2nwC5RcVJF8JgcFPIbS8apvf9tw=";
  };

  nativeBuildInputs = [
    pkg-config
    which
    makeWrapper
    qt5.wrapQtAppsHook
    autoPatchelfHook
    pythonEnv
  ];

  patches = [ ./patches/tray-icon.patch ];

  buildInputs = [
    alsa-lib
    pulseaudio
    jack2
    liblo
    file
    libsndfile
    fluidsynth
    libX11
    gtk2
    gtk3
    qt5.qtbase
    qt5.qtsvg
    qt5.qtx11extras
    pythonEnv
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  preBuild = ''
    echo "====== Carla feature matrix ======"
    make features
    echo "=================================="
  '';

  installPhase = ''
    runHook preInstall
    make install PREFIX=$out
    for bin in carla carla-control carla-database \
               carla-jack-multi carla-jack-single \
               carla-patchbay carla-rack carla-settings; do
      if [ -f "$out/bin/$bin" ]; then
        wrapProgram "$out/bin/$bin" \
          --prefix PYTHONPATH : "${pythonEnv}/${pythonEnv.sitePackages}" \
          --prefix PATH       : "${lib.makeBinPath [ pythonEnv ]}" \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ gtk2 gtk3 libX11 ]}"
      fi
    done
    for bridge in $out/lib/carla/carla-bridge-*; do
      wrapProgram "$bridge" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ gtk2 gtk3 libX11 ]}"
    done
    runHook postInstall
  '';

  meta = with lib; {
    description =
      "Fully-featured modular audio plugin host (LADSPA/DSSI/LV2/VST2/VST3/SF2/SFZ)";
    homepage = "https://kx.studio/Applications:Carla";
    license = licenses.gpl2Plus;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "carla";
  };
}
