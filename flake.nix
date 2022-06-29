{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
  };

  outputs = inputs@{ self, ... }:
  let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {
      inherit system;
    };

    lib = inputs.nixpkgs.lib;

    customos = (with pkgs; stdenv.mkDerivation {
      name = "customos";
      src = self;
      nativeBuildInputs = [
        gnumake
        grub2
        coreboot-toolchain.x64
        xorriso
      ];
      installPhase = ''
        mkdir $out
        mv dist/x86_64/kernel.iso $out/customos.iso
      '';
    });
  in {
    packages."${system}".default = customos;
    devShells."${system}".default = pkgs.mkShell {
      buildInputs = with pkgs; [
        qemu
      ] ++ customos.nativeBuildInputs;
    };
  };

}
