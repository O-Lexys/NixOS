{
  lib,
  appimageTools,
  fetchurl,
  makeWrapper,
  # Set this to pin a specific version, or leave null for latest
  # Example: "2026.102.0-lazer"
  pinnedVersion ? null,
}:

let
  pname = "osu-lazer";
  
  # If pinnedVersion is set, use it; otherwise you need to update manually
  # To find latest: curl -sI https://github.com/ppy/osu/releases/latest | grep location
  version = "2026.305.0";
  tag = "${version}-lazer";

  src = fetchurl {
    url = "https://github.com/ppy/osu/releases/download/${tag}/osu.AppImage";
    hash = "sha256-azI3PS5LIVq1H02P1Z4Bny2VFqVLUC6pwCj1UD5HA6g=";
  };

  # Extract the AppImage to get assets (icons, desktop file)
  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

in
appimageTools.wrapType2 {
  inherit pname version src;

  # Extra packages needed in the FHS environment
  extraPkgs = pkgs: with pkgs; [
    # Graphics
    libGL
    libGLU
    
    # Audio
    alsa-lib
    pipewire
    pulseaudio
    
    # Input
    libevdev
    
    # Misc
    icu
    openssl
    zlib
    
    # For hardware acceleration
    libva
    libva-vdpau-driver
    libvdpau-va-gl
  ];

  # Install desktop entry and icons
  extraInstallCommands = ''
    source "${makeWrapper}/nix-support/setup-hook"
    
    # Wrap with NVIDIA offload environment variables
    wrapProgram $out/bin/${pname} \
      --set __NV_PRIME_RENDER_OFFLOAD 1 \
      --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER "NVIDIA-G0" \
      --set __GLX_VENDOR_LIBRARY_NAME "nvidia" \
      --set __VK_LAYER_NV_optimus "NVIDIA_only"
    
    # Create symlink as "osu!"
    ln -s $out/bin/${pname} "$out/bin/osu!"
    
    # Install desktop file
    install -Dm644 ${appimageContents}/osu!.desktop $out/share/applications/osu-lazer.desktop
    
    # Fix the desktop file - use replace-warn since patterns might differ
    substituteInPlace $out/share/applications/osu-lazer.desktop \
      --replace-warn 'Exec=osu!' 'Exec=osu-lazer' \
      --replace-warn 'Exec=AppRun' 'Exec=osu-lazer'
    
    # Install icons
    for size in 16 32 48 64 128 256 512 1024; do
      if [ -f "${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/osu!.png" ]; then
        install -Dm644 \
          "${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/osu!.png" \
          "$out/share/icons/hicolor/''${size}x''${size}/apps/osu-lazer.png"
      fi
    done
    
    # Fallback: copy main icon if available
    if [ -f "${appimageContents}/osu!.png" ]; then
      install -Dm644 "${appimageContents}/osu!.png" "$out/share/icons/hicolor/256x256/apps/osu-lazer.png"
    fi
  '';

  meta = with lib; {
    description = "Rhythm is just a *click* away (official AppImage for score submission and multiplayer)";
    homepage = "https://osu.ppy.sh";
    changelog = "https://osu.ppy.sh/home/changelog/lazer/${version}";
    license = with licenses; [
      mit
      cc-by-nc-40
      unfreeRedistributable
    ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "osu-lazer";
  };
}
