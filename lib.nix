let
  sources = import ./npins;
  flake-inputs = import sources.flake-inputs;
in
{
  home-manager,
  pkgs ? import (flake-inputs { root = home-manager; }).nixpkgs { inherit system config overlays; },
  system ? builtins.currentSystem,
  config ? { },
  overlays ? [ ],
}:
rec {
  inherit pkgs;

  evaluate = configuration: import "${home-manager}/modules" { inherit pkgs configuration; };

  environment =
    configuration:
    let
      switch = pkgs.writeShellApplication {
        name = "switch";
        text = ''exec ${(evaluate configuration).activationPackage}/activate "$@"'';
      };
    in
    pkgs.mkShellNoCC { packages = [ switch ]; };
}
