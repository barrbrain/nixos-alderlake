{ pkgs ? import <nixpkgs> {
    localSystem = {
      gcc.arch = "x86-64-v3";
      gcc.tune = "alderlake";
      system = "x86_64-linux";
    };
    config = {
      packageOverrides = super: {
        python3 = super.python3.override {
          packageOverrides = python-self: python-super: {
            numpy = python-super.numpy.overridePythonAttrs (oldAttrs: {
              disabledTests = oldAttrs.disabledTests ++ ["test_validate_transcendentals"];
            });
          };
        };
        haskellPackages = super.haskellPackages.override {
          overrides = hs-self: hs-super: {
            crypton-x509-validation = super.haskell.lib.dontCheck hs-super.crypton-x509-validation;
          };
        };
      };
    };
} }:

with pkgs;
let
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
in
mkShell {
  buildInputs = [
    python-with-my-packages
  ];
}
