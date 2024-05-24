{
  sources ? import ./npins,
  system ? builtins.currentSystem,
  pkgs ? import sources.nixpkgs { inherit system; config = { }; overlays = [ ]; },
}:
let
  test = import ./test.nix;
  test-interactive = pkgs.writeShellApplication {
    name = "test-interactive";
    text = "${(pkgs.callPackage test {}).driverInteractive}/bin/nixos-test-driver";
  };
in
rec {
  shell = pkgs.mkShell {
    packages = with pkgs; [
      npins
      test-interactive
    ];
  };

  lib = pkgs.callPackage ./lib.nix { };

  inherit test;
}
