{ pkgs, ... }: {
  users.users.lioha = {
    initialPassword = "1234";
    isNormalUser = true;
    extraGroups = [
      "vboxusers"
      "dialout"
      "plugdev"
      "wheel"
      "networkmanager"
      "video"
      "plugdev"
      "render"
      "lp"
      "scanner"
    ];
    shell = pkgs.zsh;
  };
}
