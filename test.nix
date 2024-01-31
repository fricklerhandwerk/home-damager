{ pkgs }:
let
  run-test = pkgs.writeShellApplication {
    name = "run-test";
    runtimeInputs = with pkgs; [ nix ];
    text = ''
      nix-shell ${example} -A myMachine
      cowsay it works | lolcat
    '';
  };
  example = pkgs.runCommand "example" {} ''
    mkdir -p $out/npins
    cp ${./example.nix} $out/default.nix
    cp -r ${sources-mock} $out/npins/default.nix
  '';
  sources-mock = pkgs.writeText "default.nix" ''
    {
      nixpkgs = ${pkgs.path};
      home-damager = ${./.};
    }
  '';
in
pkgs.nixosTest {
  name = "home-damager-test";
  nodes.machine = { config, pkgs, ... }:
  {
    environment.systemPackages = [ run-test ];
    virtualisation.memorySize = 2048;
    virtualisation.mountHostNixStore = true;
  };
  testScript = { nodes, ... }: ''
    # this won't actually work because of the impure `fetchTarball`
    machine.succeed("${run-test}/bin/run-test")
  '';
}
