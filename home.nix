{ inputs, config, pkgs, spicePkgs, ... }:

{
  # 1. Imports
  imports = [
    ./noctalia.nix
    inputs.nixcord.homeModules.nixcord
    inputs.spicetify-nix.homeManagerModules.default
  ];

  # 3. Home Manager Core Settings
  home.username = "jazzzium";
  home.homeDirectory = "/home/jazzzium";
  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "25.11"; 

  programs.obs-studio = {
    enable = true;

    # optional Nvidia hardware acceleration
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );
  };

  programs.spicetify = {
     enable = true;
     enabledExtensions = with spicePkgs.extensions; [
       adblockify
       hidePodcasts
       shuffle # shuffle+ (special characters are sanitized out of extension names)
     ];
     theme = spicePkgs.themes.nightlight;
     #colorScheme = "Psycho";
   };

  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      esbenp.prettier-vscode
      ms-vscode.live-server
      ecmel.vscode-html-css
      rust-lang.rust-analyzer
      tamasfe.even-better-toml
      fill-labs.dependi
      viktorqvarfordt.vscode-pitch-black-theme
    ];
  };

  # 4. Packages
  home.packages = [
    pkgs.meslo-lgs-nf
    pkgs.unzip
    pkgs.unrar
    pkgs.fastfetch
    pkgs.telegram-desktop
    pkgs.vivaldi
    pkgs.vlc
    pkgs.qbittorrent
    pkgs.ani-cli
  ];

  # 5. Files and Environment
  home.file.".config/niri/config.kdl".source = ./config.kdl;
  home.file.".config/kitty/kitty.conf".source = ./kitty.conf;
  home.file.".local/share/icons/FossaCursors".source = ./FossaCursors;

  
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # 6. GNOME / GTK Settings
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  programs.nixcord = {
    enable = true;
    discord = {
        vencord.enable = false;
        equicord.enable = true;
    };
    quickCss = builtins.readFile ./themes/ClearVision-v7-BetterDiscord.theme.css;

    config = {
      useQuickCss = true;
      frameless = true;
      plugins = {
        fakeNitro.enable = true;
        betterFolders.enable = true;
        betterRoleContext.enable = true;
        crashHandler.enable = true;
        memberCount.enable = true;
        mentionAvatars.enable = true;
        messageLatency.enable = true;
        showHiddenThings.enable = true;
        showMeYourName.enable = true;
        webContextMenus.enable = true;
        webKeybinds.enable = true;
        webScreenShareFixes.enable = true;
        alwaysAnimate.enable = true;
      };
    };
  };

  programs.zsh = {
    enable = true;
    # 1. Disable the default slow completion initialization
    enableCompletion = false; 
    autosuggestion.enable = true;

    initExtraFirst = ''
      # Move P10k Instant Prompt here for the absolute fastest visual start
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '';

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    antidote = {
      enable = true;
      plugins = [
        "zsh-users/zsh-autosuggestions"
        "ohmyzsh/ohmyzsh path:lib/git.zsh"
      ];
    };

    initExtra = ''
      # Only regenerate completion cache if it's older than 24 hours
      autoload -Uz compinit
      if [[ -n ''${ZDOTDIR:-$HOME}/.zcompdump(#qN.m-1) ]]; then
        compinit -C
      else
        compinit
      fi

      # --- 2. Auto-CD & Menu ---
      setopt autocd
      zstyle ':completion:*' menu select
      zstyle ':completion:*' list-colors ""
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

      # --- 3. Powerlevel10k ---
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # (Optional) Comment out or remove zprof once you are happy with the speed
      # zprof 
    '';
  };

  programs.home-manager.enable = true;
}
