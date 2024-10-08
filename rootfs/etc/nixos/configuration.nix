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

  nixpkgs.config.allowUnfree = true; # UNFREE

  services.xserver.enable = true;
  services.xserver.videoDrivers = ["nvidia"]; # UNFREE
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

  services.openvpn.servers = {
    global = {
      config = '' config /root/nixos/openvpn/global.ovpn '';
      updateResolvConf = true;
    };
  };
  systemd.services.openvpn-global.wantedBy = lib.mkForce [];

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  users.users.barrbrain = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    packages = with pkgs; [
      appimage-run
      cargo
      clang
      ffmpeg
      file
      firefox
      gcc
      git
      kdePackages.ktorrent
      mosh
      nasm
      rust-analyzer
    ];
  };

  environment.systemPackages = with pkgs; [
    aha
    clinfo
    curl
    fwupd
    glxinfo
    htop
    input-leap
    jq
    lshw
    neovim
    pciutils
    sbsigntool
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
        "http://nix.ba.rr-dav.id.au"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix.ba-rr.dav.id.au:mN40uLqdT6zyCpfVSLl+wNZGNRrd5t/gEyJiL+tdgqc="
      ];
    };
  };

  nixpkgs.config.packageOverrides = super: {
    python3 = super.python3.override {
      packageOverrides = python-self: python-super: {
        numpy = python-super.numpy.overridePythonAttrs (oldAttrs: {
          disabledTests = oldAttrs.disabledTests ++ ["test_validate_transcendentals"];
        });
      };
    };
    haskellPackages = super.haskellPackages.override {
      overrides = hs-self: hs-super: {
        crypton-x509-validation = pkgs.haskell.lib.dontCheck hs-super.crypton-x509-validation;
      };
    };
  };
}
