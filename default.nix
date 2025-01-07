{
  sources ? import ./npins,
  system ? builtins.currentSystem,
}:
let
  inherit (lib.home-damager) pkgs;

  lib.home-damager = import ./lib.nix {
    inherit system;
    inherit (sources) home-manager;
  };

  inherit ((import sources.lazy-drv { inherit pkgs system; }).lib) lazy-drv;

  test = pkgs.callPackage ./test.nix { inherit sources; };

  lazy = lazy-drv.lazy-run {
    nix-build-args = [
      "--builders"
      ''""''
    ];
    source = "${
      with pkgs.lib.fileset;
      toSource {
        root = ./.;
        fileset = unions [
          ./default.nix
          ./lib.nix
          ./test.nix
          ./example.nix
          ./npins
        ];
      }
    }";
    attrs = {
      inherit test-interactive;
    };
  };

  test-interactive = pkgs.writeShellApplication {
    name = "test-interactive";
    text = ''exec ${pkgs.lib.getExe test.driverInteractive} "$@"'';
  };

in
rec {
  shell = pkgs.mkShellNoCC {
    packages = (with pkgs; [ npins ]) ++ (with pkgs.lib; collect isDerivation lazy);
  };

  inherit lib test test-interactive;
}
