# Fully declarative Home Manager installation

[Home Manager](https://github.com/nix-community/home-manager/) is great.
It allows configuring user environments fully declaratively.

But [installing Home Manager](https://github.com/nix-community/home-manager/blob/d634c3abafa454551f2083b054cd95c3f287be61/docs/manual/installation/standalone.md) has always been wrong:
Channels are bad, `nix-env` is bad.
And [Home Manager dropping a `flake.nix`](https://github.com/nix-community/home-manager/blob/d634c3abafa454551f2083b054cd95c3f287be61/home-manager/home-manager#L417-L445) *somewhere* is also bad.

While Home Manager environments are declarative, installation is not!

In my opinion, installing Home Manager should work like this:

1. Add a `default.nix` in a directory of choice.

2. Import the Home Manager Nix library from there.

3. Put your configuration and custom modules wherever you please.

4. Add attributes to `default.nix` that correspond to the machines or profiles or users you're managing.

5. Run `nix-shell -A <attribute>` to instantly switch to an environment.

6. In an existing environment, run `home-manager switch` as usual.

This repository implements such a wrapper around Home Manager, which you can use as just described.
It will match the Home Manager release to the version of Nixpkgs in use for the given expression.

# Example

Start by adding remote sources:

```console
nix-shell -p npins --run $SHELL
npins init --bare
npins add github nixos nixpkgs --branch nixos-23.11
npins add github fricklerhandwerk home-damager
```

Then the entry point to your set of Home Manager configurations can have this structure:

```nix
{
  sources ? import ./npins,
  system ? builtins.currentSystem,
}:
let
  pkgs = import sources.nixpkgs {
    config = {};
    overlays = [];
    inherit system;
  };
  home-damager = import sources.home-damager { inherit sources system; };
  home-manager = pkgs.callPackage home-damager.package {};
in
rec {
  myMachine = home-manager.environment myConfiguration;
  myConfiguration = { pkgs, ... }: {
    home.packages = with pkgs; [ cowsay lolcat ];

    home.username = "myUser";
    # don't do this in practice. impurities bad.
    home.homeDirectory = ~/.;
    home.stateVersion = "23.11";
  };
}
```
