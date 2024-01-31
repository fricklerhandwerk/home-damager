{ pkgs }:
rec {
  version = with pkgs; lib.versions.majorMinor lib.version;

  # XXX: this must be an impure reference.
  # if `pkgs.fetchFromGitHub` was used here, specifying a commit hash would be required.
  # this makes it essentially un-testable automatically in a NixOS VM...
  home-manager = fetchTarball {
    name = "home-manager-${version}";
    url = "https://github.com/nix-community/home-manager/tarball/release-${version}";
  };

  evaluate = configuration:
    import "${home-manager}/modules" {
      inherit pkgs configuration;
    };

  environment = configuration:
    pkgs.mkShell {
      shellHook = "exec ${(evaluate configuration).activationPackage}/activate";
    };
}
