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
    ];
  };
in
{
  inherit shell;
}
