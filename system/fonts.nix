{ pkgs, ... }:
{
  fonts = {
    packages =
      with pkgs;
      [ material-icons ]
      ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
    fontDir.enable = true;
  };
}
