{
  pkgs,
  lib,
  ...
}:
{
  home.sessionVariables = {
    #LV2_PATH = "$HOME/.local/state/nix/profiles/home-manager/lib/lv2:/run/current-system/sw/lib/lv2";
    LADSPA_PATH = "$HOME/.local/state/nix/profiles/home-manager/lib/ladspa:/run/current-system/sw/lib/ladspa";
    DSSI_PATH = "$HOME/.local/state/nix/profiles/home-manager/lib/dssi:/run/current-system/sw/lib/dssi";
    CLAP_PATH = "$HOME/.local/state/nix/profiles/home-manager/lib/clap:/run/current-system/sw/lib/clap";
    VST_PATH = "$HOME/.vst:$HOME/.local/state/nix/profiles/home-manager/lib/vst:/run/current-system/sw/lib/vst";
    VST3_PATH = "$HOME/.vst3:$HOME/.local/state/nix/profiles/home-manager/lib/vst3:/run/current-system/sw/lib/vst3";
  };
  home.sessionVariables.LV2_PATH = lib.makeSearchPath "lib/lv2" [
    pkgs.calf
    pkgs.x42-plugins
    pkgs.zam-plugins
    pkgs.eq10q
    pkgs.mda_lv2
    pkgs.swh_lv2
    pkgs.noise-repellent
    pkgs.distrho-ports
    pkgs.aether-lv2
    pkgs.bolliedelayxt-lv2
    pkgs.fluida-lv2
  ];
}
