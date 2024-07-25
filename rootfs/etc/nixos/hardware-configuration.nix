{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.loader.timeout = 0;
  boot.initrd.availableKernelModules = [ "thunderbolt" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModprobeConfig = ''
    options i915          force_probe=7d55
  '';
  boot.extraModulePackages = [ ];

  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_6.override {
    argsOverride = rec {
      src = pkgs.fetchurl {
            url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
            sha256 = "10z6fjvpiv3l11rpsd6fgi7dr6a3d38c6zlp8ihffx6pjz1ch0c8";
      };
      version = "6.6.42";
      modDirVersion = "6.6.42";
      };
  });

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  fileSystems = {
    "/".device = "none";
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = {
    gcc.arch = "alderlake";
    gcc.tune = "alderlake";
    system = "x86_64-linux";
  };
  nix.settings.system-features = [
    "nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-alderlake"
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
