{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "auto";
  boot.loader.systemd-boot.xbootldrMountPoint = "/boot";

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/efi";

  networking.hostName = "battleship";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Seoul";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    earlySetup = true;
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  fonts.packages = with pkgs; [
    stix-two
    iosevka
    sarasa-gothic
    source-han-mono
    source-han-sans-korean
    source-han-serif-korean
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];

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

  services.openssh.enable = true;

  services.libinput.enable = true;

  services.fwupd.enable = true;

  services.envfs.enable = true;
  programs.nix-ld.enable = true;

  programs.direnv.enable = true;
  programs.firefox.enable = true; # UNFREE
  programs.firefox.package = pkgs.firefox-bin; # UNFREE

  systemd.services.systemd-vconsole-setup.unitConfig.After = "local-fs.target";

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
      b3sum
      bc
      binaryen
      cargo
      clang
      config.boot.kernelPackages.perf
      ffmpeg
      file
      gcc
      git
      google-cloud-sdk
      # kdePackages.falkon
      kdePackages.ktorrent
      lapce
      mosh
      nasm
      pigz
      pixz
      rust-analyzer
      wabt
      nodePackages.webpack-cli
    ];
  };

  environment.systemPackages = with pkgs; [
    aha
    clinfo
    curl
    fwupd
    htop
    input-leap
    jq
    lshw
    mesa-demos
    minicom
    neovim
    pciutils
    sbctl
    sbsigntool
    sof-firmware
    usbutils
    vulkan-tools
    wayland-utils
    (let
      my-python-packages = python-packages: with python-packages; [
        seaborn
        statsmodels
      ];
      python3Optimized = pkgs.python3.override {
        enableLTO = true;
        enableOptimizations = true;
        reproducibleBuild = false;
        self = python3Optimized;
      };
      python-with-my-packages = python3Optimized.withPackages my-python-packages;
    in pkgs.runCommand "python-seaborn" {
      buildInputs = [ python-with-my-packages ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
      mkdir -p $out/bin/
      ln -s ${python-with-my-packages}/bin/python $out/bin/python-seaborn
      wrapProgram $out/bin/python-seaborn --prefix PATH : ${pkgs.lib.makeBinPath [ python-with-my-packages ]}
    '')
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
}
