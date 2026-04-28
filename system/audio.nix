{ ... }:
{
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    jack.enable = true;
  };
  environment.pathsToLink = [
    "/lib/lv2"
    "/lib/ladspa"
    "/lib/vst"
    "/lib/vst3"
  ];

  # Tell Carla (and other apps) where to find them
  environment.variables = {
    LV2_PATH = "/run/current-system/sw/lib/lv2";
    LADSPA_PATH = "/run/current-system/sw/lib/ladspa";
    VST_PATH = "/run/current-system/sw/lib/vst";
    VST3_PATH = "/run/current-system/sw/lib/vst3";
  };
}
