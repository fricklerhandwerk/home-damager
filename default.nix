{
  sources ? import ./npins,
  system ? builtins.currentSystem,
}:
let
  pkgs = import sources.nixpkgs {
    inherit system;
    config = { };
    overlays = [ ];
  };

  shell = pkgs.mkShell {
    packages = with pkgs; [
      npins
      test-interactive
    ];
  };

  lib = import ./lib.nix;

  test = import ./test.nix;

  test-interactive = pkgs.writeShellApplication {
    name = "test-interactive";
    text = "${(pkgs.callPackage test {}).driverInteractive}/bin/nixos-test-driver";
  };
in
{
  inherit
    shell
    lib
    test
  ;
}
