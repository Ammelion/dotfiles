{
  description = "My Flake!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcord.url = "github:kaylorben/nixcord";
    nixcord.inputs.nixpkgs.follows = "nixpkgs";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    aagl.url = "github:ezKEa/aagl-gtk-on-nix";
    aagl.inputs.nixpkgs.follows = "nixpkgs";
  };

  # 1. Capture 'inputs' in the outputs function
  outputs = { self, nixpkgs, silentSDDM, home-manager, flake-utils, aagl, noctalia, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    vcr-osd-mono = pkgs.stdenvNoCC.mkDerivation {
      name = "vcr-osd-mono";
      src = ./my-fonts;
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/share/fonts/truetype
        cp $src/vcr_osd_mono.ttf $out/share/fonts/truetype/
      '';
    };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      # 2. Inherit inputs here so your system config can see Noctalia
      specialArgs = { inherit inputs vcr-osd-mono; }; 

      modules = [
        ./configuration.nix
        silentSDDM.nixosModules.default
        aagl.nixosModules.default
        {
          nix.settings = aagl.nixConfig;
          programs.anime-game-launcher.enable = true;
          programs.anime-games-launcher.enable = false;

          programs.silentSDDM = {
            enable = true;
            theme = "ken";
            profileIcons = {
              jazzzium = ./avatars/jazzzium.png;
            };
          };

          fonts.packages = [ vcr-osd-mono ];
          services.xserver.enable = true;
          services.displayManager.sddm.enable = true;
          
          # 3. Required system options for Noctalia shell features
          networking.networkmanager.enable = true;
          hardware.bluetooth.enable = true;
          services.upower.enable = true;
        }
      ];
    };

    homeConfigurations.jazzzium = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      # 4. Pass inputs to Home Manager
      extraSpecialArgs = { inherit inputs vcr-osd-mono; }; 
      modules = [ ./home.nix ];
    };
  };
}
