{
  pkgs,
  ...
}:
{
  programs.obs-studio = {
    enable = true;

    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-tuna
      obs-shaderfilter
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-transition-table
      obs-move-transition
      #obs-vaapi
      #obs-vkcapture
      obs-advanced-masks
      obs-gradient-source
      obs-3d-effect
      #obs-rgb-levels-filter
      #obs-nvfbc
      droidcam-obs
      obs-move-transition
      #advanced-scene-switcher
      waveform
      #obs-vintage-filter
      #obs-transition-table
      #obs-source-switcher
      obs-scale-to-sound
      #obs-mute-filter
      #obs-composite-blur
    ];
  };
}
