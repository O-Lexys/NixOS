{ lib, stdenv }:

stdenv.mkDerivation {
  pname = "Lazer";
  version = "1.0";

  src = ./.;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons/Lazer
    cp -r $src/* $out/share/icons/Lazer/

    runHook postInstall
  '';

  meta = with lib; {
    description = "I like osu!lazer cursor, dont you?";
    platforms = platforms.linux;
  };
}

