{
  sources ? import ./npins,
  system ? builtins.currentSystem,
  home-damager ? (import sources.home-damager { inherit system sources; }).lib.home-damager,
}:
rec {
  myMachine = home-damager.environment myConfiguration;
  myConfiguration =
    { config, pkgs, ... }:
    {
      home.packages = with pkgs; [
        cowsay
        lolcat
      ];
      home.stateVersion = "24.11";
      home.username = "root";
      home.homeDirectory = "/root";
    };
}
