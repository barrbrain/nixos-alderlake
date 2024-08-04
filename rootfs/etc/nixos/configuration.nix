{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "battleship";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Seoul";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # nixpkgs.config.allowUnfree = true;

  services.xserver.enable = true;
  # services.xserver.videoDrivers = ["nvidia"];
  services.xserver.xkb.layout = "us";
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "barrbrain";
  services.displayManager.defaultSession = "plasma";
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;

  services.fwupd.enable = true;

  programs.direnv.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  users.users.barrbrain = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    packages = with pkgs; [
      cargo
      clang
      ffmpeg
      # firefox
      gcc
      git
      mosh
      rust-analyzer
    ];
  };

  environment.systemPackages = with pkgs; [
    aha
    clinfo
    curl
    fwupd
    glxinfo
    jq
    lshw
    neovim
    pciutils
    sof-firmware
    vulkan-tools
    wayland-utils
  ];
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  networking.firewall.enable = false;

  system.stateVersion = "24.05";

  nix = {
    settings = {
      experimental-features = [
        "flakes"
        "nix-command"
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://barrbrain-alderlake.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "barrbrain-alderlake.cachix.org-1:r9gP8dmB5joRXT6L0303quClxuCUN6kh5zIPLpm6Gj8="
      ];
    };
  };

  nixpkgs.config.packageOverrides = super: {
    python3 = super.python3.override {
      packageOverrides = python-self: python-super: {
        numpy = python-super.numpy.overridePythonAttrs (oldAttrs: {
          disabledTests = oldAttrs.disabledTests ++ ["test_validate_transcendentals"];
        });
        pillow = python-super.pillow.overridePythonAttrs (oldAttrs: {
          disabledTests = oldAttrs.disabledTests ++ [
            "test_fuzz_images"
          ];
          disabledTestPaths = [
            "Tests/test_file_libtiff.py"
          ];
        });
      };
    };
    haskellPackages = super.haskellPackages.override {
      overrides = hs-self: hs-super: {
        crypton = pkgs.haskell.lib.dontCheck hs-super.crypton;
        crypton-x509-validation = pkgs.haskell.lib.dontCheck hs-super.crypton-x509-validation;
        cryptonite = pkgs.haskell.lib.dontCheck hs-super.cryptonite;
        tls = pkgs.haskell.lib.dontCheck hs-super.tls;
      };
    };
    x265 = super.x265.overrideAttrs {
      doCheck = false;
    };
  };
}
