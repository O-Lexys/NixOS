{
  pkgs,
  config,
  ...
}:
{
  programs.zsh.plugins = [
    {
      name = "zsh-vi-mode";
      src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
    }
    {
      name = "fzf-tab";
      src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
    }
  ];

  programs.zsh = {

    oh-my-zsh = {
      enable = true;

      #   theme = "powerlevel10k/powerlevel10k";
      plugins = [ "git" ];
      #   custom = "${pkgs.zsh-powerlevel10k}/share/zsh/themes/";
    };

    completionInit = ''
      __nix_compinit() {
        autoload -U compinit

        typeset cache hm_profile hm_id sys_link sys_id dump

        cache="$HOME/.cache/zsh"
        [[ -n "$XDG_CACHE_HOME" ]] && cache="$XDG_CACHE_HOME/zsh"
        mkdir -p -- "$cache"

        hm_profile="$HOME/.nix-profile"
        [[ -e "/etc/profiles/per-user/$USER" ]] && hm_profile="/etc/profiles/per-user/$USER"

        hm_id="no-hm"
        [[ -e "$hm_profile" ]] && hm_id="''${hm_profile:A:t}"

        sys_link="/run/current-system"
        sys_id="no-system"
        [[ -e "$sys_link" ]] && sys_id="''${sys_link:A:t}"

        dump="$cache/zcompdump-$ZSH_VERSION-$sys_id-$hm_id"
        compinit -C -d "$dump"
      }

      __nix_compinit
      unset -f __nix_compinit
    '';

    # oh-my-zsh = {
    #   enable = true;
    #   plugins = [
    #     "git"         # also requires `programs.git.enable = true;`
    #     "z"
    #   {
    #     name = "powerlevel10k";
    #     src = pkgs.zsh-powerlevel10k;
    #     file = "${pkgs.zsh-powerlevel10k}/share/zsh/themes/powerlevel10k.zsh-theme";
    #   }
    #   ];
    #   theme = "powerlevel10k";
    # };
    enable = true;
    autocd = true;
    dotDir = config.xdg.configHome + "/zsh";
    autosuggestion.enable = true;
    defaultKeymap = "emacs";
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      cd = "z";
      fuck = "reboot";
      blya = "echo 'не лайся'";
      D = "yt-dlp";
      ll = "ls -al";
      Animefetch = "fastfetch -l ~/Pictures/fetch.jpg --logo-width 28";
      fetch = "nix run nixpkgs#nitch";
      Nfu = "cd ~/nix && nix flake update";
      Osw = "nh os switch /home/lioha/nix/";
      Hsw = "nh home switch /home/lioha/nix/";
      #     rebuild = "sudo nixos-rebuild switch --flake ~/nix";
      #     hupdate = "home-manager switch --flake ~/nix";
    };
    initContent = ''
      #     cat ~/.cache/wal/sequences
      #     export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
            export SHELL=/run/current-system/sw/bin/bash
            eval "$(zoxide init zsh)"
            export STARSHIP_CONFIG=~/.config/starship/starship.toml
    '';

    history = {
      size = 100000;
      ignoreAllDups = true;
      ignoreSpace = true;
      path = "/home/lioha/.zsh_history";
    };
  };
}
