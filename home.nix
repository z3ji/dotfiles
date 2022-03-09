{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./private.nix
  ];

  home.stateVersion = "21.05";

  # Programs Configuration
  programs.neomutt = {
    enable = true;
    package = (import <nixos-stable> {}).neomutt;
    sidebar.enable = true;
    vimKeys = true;
  };

  programs.mpv = {
    enable = true;
    defaultProfiles = ["main"];
    profiles.main = {
      vo = "vdpau";
      alang = "en";
      slang = "en";
      vlang = "en";
    };
    scripts = [];
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
  };

  programs.home-manager.enable = true;

  # Wayland Window Manager Configuration
  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.sway;

    wrapperFeatures.gtk = true;
    config = {
      bars = [
        {
          command = "${pkgs.waybar}/bin/waybar";
          mode = "dock";
          position = "top";
        }
      ];
      colors = {
        focused = {
          background = "#913131";
          border = "#913131";
          childBorder = "#b35656";
          indicator = "#b35656";
          text = "#ebdadd";
        };
        focusedInactive = {
          background = "#782a2a";
          border = "#782a2a";
          childBorder = "#b32d2d";
          indicator = "#b32d2d";
          text = "#ebdadd";
        };
        placeholder = {
          background = "#24101a";
          border = "#24101a";
          childBorder = "#24101a";
          indicator = "#000000";
          text = "#ebdadd";
        };
        unfocused = {
          background = "#4d2525";
          border = "#472222";
          childBorder = "#4d2525";
          indicator = "#661a1a";
          text = "#8c8284";
        };
        urgent = {
          background = "#993d3d";
          border = "#734545";
          childBorder = "#993d3d";
          indicator = "#993d3d";
          text = "#ebdadd";
        };
      };
      fonts = {
        names = ["Noto Sans" "Noto Emoji" "FontAwesome5Free"];
        size = 11.0;
      };
      floating = {
        titlebar = true;
      };
      gaps = {
        smartBorders = "on";
        smartGaps = true;
        inner = 10;
      };
      startup = [
        {
          always = true;
          command = "${pkgs.wl-clipboard}/bin/wl-paste -t text --watch clipman store --no-persist";
        }
      ];
      input = {
        "*" = {
          xkb_layout = "en";
          xkb_options = "caps:swapescape,compose:menu";
        };
      };
      modifier = "Mod4";
      menu = "${pkgs.bemenu}/bin/bemenu-run --no-overlap --prompt '>' --tb '#24101a' --tf '#ebbe5f' --fb '#24101a' --nb '#24101a70' --nf '#ebdadd' --hb '#394893' --hf '#e66e6e' --list 30 --prefix '*' --scrollbar autohide --fn 'Noto Sans Mono' --line-height 23 --sb '#394893' --sf '#ebdadd' --scb '#6b4d52' --scf '#e66e6e'";
      output = {
        "*" = {bg = "~/wallpaper.jpg fill";};
      };
      window = {
        hideEdgeBorders = "smart";
      };
    };
    extraSessionCommands = ''
      export BEMENU_BACKEND=wayland
      export BEMENU_OPTS="--no-overlap --prompt '>' --tb '#24101a' --tf '#ebbe5f' --fb '#24101a' --nb '#24101a70' --nf '#ebdadd' --hb '#394893' --hf '#e66e6e' --list 30 --prefix '*' --scrollbar autohide --fn 'Noto Sans Mono' --line-height 23 --sb '#394893' --sf '#ebdadd' --scb '#6b4d52' --scf '#e66e6e'"
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export _JAVA_AWT_WM_NONREPARENTING=1
      export QT_QPA_PLATFORMTHEME=gnome
      export GTK_IM_MODULE=fcitx
      export QT_IM_MODULE=fcitx
      export XMODIFIERS=@im=fcitx
      export SDL_IM_MODULE=fcitx
      export XIM_SERVERS=fcitx
      export INPUT_METHOD=fcitx
      export MOZ_ENABLE_WAYLAND=1
    '';
  };

  # Services Configuration
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.sway}/bin/swaymsg \"output * dpms off\"";
        resumeCommand = "${pkgs.sway}/bin/swaymsg \"output * dpms on\"";
      }
    ];
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      ${pkgs.gnupg}/bin/gpg-connect-agent --quiet updatestartuptty /bye > /dev/null
    '';
    shellInit = ''
      set PATH ~/bin/:$PATH
      set BEMENU_BACKEND wayland
      set BEMENU_OPTS "--no-overlap --prompt '>' --tb '#24101a' --tf '#ebbe5f' --fb '#24101a' --nb '#24101a70' --nf '#ebdadd' --hb '#394893' --hf '#e66e6e' --list 30 --prefix '*' --scrollbar autohide --fn 'Noto Sans Mono' --line-height 23 --sb '#394893' --sf '#ebdadd' --scb '#6b4d52' --scf '#e66e6e'"
      set SDL_VIDEODRIVER wayland
      set QT_QPA_PLATFORM wayland
      set QT_WAYLAND_DISABLE_WINDOWDECORATION 1
      set _JAVA_AWT_WM_NONREPARENTING 1
      set QT_QPA_PLATFORMTHEME gnome
    '';
    shellAbbrs = {};
  };

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    extraConfig = ''
      autocmd BufReadPost * if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
    '';
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = let
      githubRef = ref: repo: name:
        pkgs.vimUtils.buildVimPluginFrom2Nix {
          pname = name;
          version = ref;
          src = builtins.fetchGit {
            url = "https://github.com/${repo}.git";
            ref = ref;
          };
        };
      github = githubRef "HEAD";
    in
      with pkgs.vimPlugins; [
        (github "tpope/vim-sleuth" "sleuth")
      ];
  };

  programs.mako = {
    enable = true;
  };

  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = ["sway/workspaces" "sway/window" "sway/mode"];
        modules-right = ["cpu" "memory" "battery" "tray" "pulseaudio" "clock" "sway/language"];
        tray = {
          icon-size = 21;
          spacing = 10;
        };
        cpu = {
          states = {
            warning = 50;
            critical = 90;
          };
          format = "{usage}% ";
        };
        battery = {
          states = {
            warning = 35;
            critical = 10;
          };
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-time = "{H}:{M}";
          format = "{capacity}% {icon}";
          format-icons = ["" "" "" "" ""];
        };
        clock = {
          format = "{:%Y-%m-%d %H:%M:%S}";
          today-format = "{}";
        };
        pulseaudio = {
          format = "{volume}% 🔊";
          format-muted = "🔇";
          format-source = "{volume}% 🎙️";
          format-source-muted = "Muted 🎙️";
        };
        memory = {
          states = {
            warning = 50;
            critical = 90;
          };
          format = "{}% ";
        };
      }
    ];
    style = builtins.readFile ./waybar.css;
  };

  programs.urxvt = {
    enable = true;
    keybindings = {
      "Control-Alt-C" = "builtin-string:";
      "Control-Alt-V" = "builtin-string:";
    };
    extraConfig = {
      depth = 32;
      inheritPixmap = true;
    };
    scroll.bar.enable = false;
    fonts = ["xft:Noto Sans Mono:pixelsize=16"];
  };

  # Xresources Configuration
  xresources.properties = {
    "*.foreground" = "#ebdadd";
    "*.background" = "[75]#24101a";
    "*.cursorColor" = "#ebdadd";
    "*.color0" = "#523b3f"; # "#3b4252";
    "*.color8" = "#6b4d52"; # "#4c566a";
    "*.color1" = "#e66e6e";
    "*.color9" = "#e66e6e";
    "*.color2" = "#8cbf73";
    "*.color10" = "#8cbf73";
    "*.color3" = "#ebbe5f";
    "*.color11" = "#ebbe5f";
    "*.color4" = "#5968b3";
    "*.color12" = "#5968b3";
    "*.color5" = "#a64999";
    "*.color13" = "#a64999";
    "*.color6" = "#77c7c2";
    "*.color14" = "#77c7c2";
    "*.color7" = "#f0e4e6";
    "*.color15" = "#f7f0f1";
    "*antialias" = true;
    "*autohint" = true;
  };

  # Packages Configuration
  home.packages = with pkgs; [
    wl-clipboard
    qt5ct
    clipman
    grim
    slurp
    keepassxc
    nyxt
    qutebrowser
    nheko
    rclone
    fuse
    jq
    imagemagick
    ffmpeg
    appimage-run
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    font-awesome
    qgnomeplatform
  ];

  # GPG Configuration
  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
    mutableKeys = true;
    mutableTrust = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    maxCacheTtl = 72000;
    maxCacheTtlSsh = 72000;
  };

  services.kdeconnect.enable = true;

  systemd.user.services = {
    fcitx5-daemon = {
      Unit.After = "graphical-session-pre.target";
      Service = {
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    delta.enable = true;
  };

  programs.fzf = {
    enable = true;
  };

  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    font.name = "Noto Sans";
    font.size = 10;
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    theme = {
      package = pkgs.breeze-gtk;
      name = "Breeze-Dark";
    };
  };

  programs.ssh = {
    enable = true;
    compression = true;
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    customPaneNavigationAndResize = true;
    keyMode = "en";
  };

  services.gammastep.enable = true;
}
