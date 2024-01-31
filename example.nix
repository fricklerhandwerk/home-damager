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
  home-damager = import sources.home-damager {
    inherit sources system;
  };
  home-manager = pkgs.callPackage home-damager.lib {};
in
rec {
  myMachine = home-manager.environment myConfiguration;
  myConfiguration = { config, pkgs, ... }: {
    home.packages = with pkgs; [ cowsay lolcat ];
    home.stateVersion = "23.11";
    home.username = "root";
    home.homeDirectory = "/root";
  };
}
