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

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.binfmt.preferStaticEmulators = true;

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
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
