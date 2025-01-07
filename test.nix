{
  sources,
  nix,
  runCommand,
  testers,
  writeShellApplication,
  writeText,
}:
let
  flake-inputs = import sources.flake-inputs;
  nixpkgs = (flake-inputs { root = sources.home-manager; }).nixpkgs;
  run-test = writeShellApplication {
    name = "run-test";
    runtimeInputs = [ nix ];
    text = ''
      nix-shell ${example} -A myMachine -I nixpkgs=${nixpkgs} --run switch
      cowsay it works | lolcat
    '';
  };
  example = runCommand "example" { } ''
    mkdir -p $out/npins
    cp ${./example.nix} $out/default.nix
    cp -r ${sources-mock} $out/npins/default.nix
  '';
  sources-mock = writeText "default.nix" ''
    {
      home-manager = ${sources.home-manager};
      flake-inputs = ${sources.flake-inputs};
      home-damager = ${./.};
    }
  '';
in
testers.runNixOSTest {
  name = "home-damager-test";
  nodes.machine =
    { config, ... }:
    {
      environment.systemPackages = [ run-test ];
      virtualisation.memorySize = 2048;
      virtualisation.additionalPaths = [
        # XXX: since all of this runs in a derivation and can't access the internet,
        # we need the Nixpkgs source picked up from Home Manager
        "${nixpkgs}"
        # and the built closure of the desired environmet
        (import example { }).myMachine
      ];
    };
  testScript =
    { nodes, ... }:
    ''
      machine.succeed("run-test")
    '';
}
