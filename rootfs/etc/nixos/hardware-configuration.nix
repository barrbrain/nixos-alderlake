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
            sha256 = "0l2gav312b12w5gxcjynca5caafkc38ln196p6qjpagax74pccyl";
      };
      version = "6.6.47";
      modDirVersion = "6.6.47";
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
        version = "550.107.02";
        sha256_64bit = "sha256-+XwcpN8wYCjYjHrtYx+oBhtVxXxMI02FO1ddjM5sAWg=";
        sha256_aarch64 = "sha256-mVEeFWHOFyhl3TGx1xy5EhnIS/nRMooQ3+LdyGe69TQ=";
        openSha256 = "sha256-Po+pASZdBaNDeu5h8sgYgP9YyFAm9ywf/8iyyAaLm+w=";
        settingsSha256 = "sha256-WFZhQZB6zL9d5MUChl2kCKQ1q9SgD0JlP4CMXEwp2jE=";
        persistencedSha256 = "sha256-Vz33gNYapQ4++hMqH3zBB4MyjxLxwasvLzUJsCcyY4k=";
    };
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
