{
  sources ? import ./npins,
  system ? builtins.currentSystem,
  pkgs ? import sources.nixpkgs { inherit system; config = { }; overlays = [ ]; },
  home-damager ? pkgs.callPackage sources.home-damager { };
}:
rec {
  myMachine = home-manager.lib.environment myConfiguration;
  myConfiguration = { config, pkgs, ... }: {
    home.packages = with pkgs; [ cowsay lolcat ];
    home.stateVersion = "23.11";
    home.username = "root";
    home.homeDirectory = "/root";
  };
}
