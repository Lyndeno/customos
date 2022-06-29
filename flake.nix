{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
  };

  outputs = inputs@{ self, ... }:
  let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {
      inherit system;
      crossSystem = {
        config = "x86_64-elf";
        libc = "newlib";
      };
    };

    lib = inputs.nixpkgs.lib;

    customos = (with pkgs; stdenv.mkDerivation {
      name = "customos";
      src = self;
      nativeBuildInputs = [
        buildPackages.gnumake
        buildPackages.grub2
        #coreboot-toolchain.x64
        buildPackages.xorriso
        buildPackages.nasm
      ];
      installPhase = ''
        mkdir $out
        mv dist/x86_64/kernel.iso $out/customos.iso
      '';
    });
  in {
    packages."${system}".default = customos;
    devShells."${system}".default = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        buildPackages.buildPackages.qemu
      ] ++ customos.nativeBuildInputs;
      buildInputs = customos.buildInputs;
    };
  };

}
