# Theme for graphical apps
{ lib, pkgs, ... }:
let
  gtk-theme = "Breeze-Dark";
  gtk-icons = "Breeze Dark";

  kde-theme = "Breeze";
  kde-icons = "breeze-dark";
  kde-font = ''"Fixel Text Medium,14,-1,5,500,0,0,0,0,0,0,0,0,0,0,1,Regular"'';
in {

  home.packages = with pkgs; [
    kdePackages.breeze.qt5
    kdePackages.breeze
    qt6ct-kde
  ];

  # Cursor setup
  home.pointerCursor = {
    package = pkgs.Lazer;
    name = "Lazer";
    size = 24;
    gtk.enable = true;
    x11 = { enable = true; };
  };

  # GTK Setup
  gtk = {
    enable = true;
    theme = {
      name = gtk-theme;
      package = pkgs.kdePackages.breeze-gtk;
    };
    iconTheme = {
      name = lib.mkForce gtk-icons;
      package = lib.mkForce pkgs.kdePackages.breeze-icons;
    };

    gtk3 = {
      bookmarks = [ ];
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };
  dconf.settings = {
    "org/gtk/settings/file-chooser" = { sort-directories-first = true; };

    # GTK4 Setup
    "org/gnome/desktop/interface" = {
      gtk-theme = gtk-theme;
      color-scheme = "prefer-dark";
    };
  };

  xdg.configFile = {
    qt6full = {
      target = "qt6ct/qt6ct.conf";
      text = lib.generators.toINI { } {

        Appearance = {
          color_scheme_path =
            "${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors";
          custom_palette = "true";
          icon_theme = kde-icons;
          standard_dialogs = "default";
          style = kde-theme;
        };
        Fonts = {
          fixed = kde-font;
          general = kde-font;
        };
        Interface = {
          activate_item_on_single_click = "1";
          buttonbox_layout = "3";
          cursor_flash_time = "1000";
          dialog_buttons_have_icons = "1";
          double_click_interval = "400";
          gui_effects =
            "General, AnimateMenu, AnimateCombo, AnimateTooltip, AnimateToolBox";
          keyboard_scheme = "3";
          menus_have_icons = "true";
          show_shortcuts_in_context_menus = "true";
          stylesheets = "@Invalid()";
          toolbutton_style = "4";
          underline_shortcut = "1";
          wheel_scroll_lines = "3";
        };
        SettingWindow = {
          geometry =
            "@ByteArray(x1xd9xd0xcb0x3000000000000x4+00x2xcd0000000000x5-00x4x1d0000x2000ax800000000000x4+00x2xcd)";
        };
        Troubleshooting = {
          force_raster_widgets = "1";
          ignored_applications = "@Invalid()";
        };
      };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "qt6ct";
  };
}
