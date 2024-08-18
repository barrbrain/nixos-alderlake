{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.loader.timeout = 0;
  boot.initrd.availableKernelModules = [ "thunderbolt" ];
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
  ];
  boot.kernelModules = [
    "kvm-intel"
    "nvidia_drm"
  ];
  boot.kernelParams = [
    "quiet"
  ];
  boot.extraModprobeConfig = ''
    options i915             force_probe=7d55
  '';
  boot.extraModulePackages = [ ];

  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_6.override {
    argsOverride = rec {
      src = pkgs.fetchurl {
            url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
            sha256 = "1wj5vn8dj0ln85n1xr5xi0hw35zpirm254fsxr6diiyrjqir6bq5";
      };
      version = "6.6.46";
      modDirVersion = "6.6.46";
      };
  });

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  fileSystems = {
    "/".device = "none";
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = {
    gcc.arch = "x86-64-v3";
    gcc.tune = "alderlake";
    system = "x86_64-linux";
  };
  nix.settings.system-features = [
    "nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-x86-64-v3"
  ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.opengl.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "550.100";
        sha256_64bit = "sha256-imtfsoe/EfUFZzR4S9pkwQZKCcKqefayJewPtW0jgC0=";
        sha256_aarch64 = "sha256-AWHdMtCci8i7maNjVapOT6kyVuFaP81jJyTRLjEyMzo=";
        openSha256 = "sha256-3g0f88xGMTB0mx4kVan3ipLtnJFFIKi58ss/1lqC3Sw=";
        settingsSha256 = "sha256-cDxhzZCDLtXOas5OlodNYGIuscpKmIGyvhC/kAQaxLc=";
        persistencedSha256 = "sha256-gXHBR2+1+YZE2heRArfrZpEF3rO7R92ChuQN+ISpil8=";
    };
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
