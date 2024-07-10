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

  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";

  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;

  users.users.barrbrain = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      # firefox
      git
    ];
  };

  environment.systemPackages = with pkgs; [
    curl
    neovim
  ];

  networking.firewall.enable = false;

  system.stateVersion = "24.05";

  nix = {
    settings = {
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
  };
}
