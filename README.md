# Fully declarative Home Manager installation

[Home Manager](https://github.com/nix-community/home-manager/) is great.
It allows configuring user environments fully declaratively.

But [installing Home Manager](https://github.com/nix-community/home-manager/blob/d634c3abafa454551f2083b054cd95c3f287be61/docs/manual/installation/standalone.md) has always been wrong:
Channels are bad, `nix-env` is bad.
And [Home Manager dropping a `flake.nix`](https://github.com/nix-community/home-manager/blob/d634c3abafa454551f2083b054cd95c3f287be61/home-manager/home-manager#L417-L445) *somewhere* is also bad.

While Home Manager environments are declarative, installation is not!

In my opinion, using Home Manager should work like this:

1. Add a `default.nix` in a directory of choice.

2. Import the Home Manager Nix library from there.

3. Put your configuration and custom modules wherever you please.

4. Add attributes to `default.nix` that correspond to the machines or profiles or users you're managing.

5. Run `nix-shell -A <attribute> --run switch` to instantly switch to an environment.

6. In an existing environment, run `home-manager switch` as usual.

This repository implements such a wrapper around Home Manager, which you can use as just described.

# Background

The underlying problem is that we've been doing it backwards this entire time.
Nix is still being misunderstood as a user-facing application, while really it's a low-level library that *actual* applications can build upon to do useful things.

Home Manager is such an application, which strongly depends on Nixpkgs, which in turn strongly depends on the Nix language and the Nix store.
Note how the Nix CLI doesn't even get an honorable mention here.

This is why with `home-damager` you import and keep updated a Home Manager release and use the version of Nixpkgs shipped with Home Manager, not the other way around.
Passing your own arbitrary Nixpkgs is merely an escape hatch, such as for emergency updates, and should be a very deliberate exception.

Driven to conclusion, Home Manager should have its own first-class installer and bring its own Nix under the hood.

# Example

Check [`example.nix`](./example.nix) for the structure of the entry point to your set of Home Manager configurations.

To use it, get a copy and add remote sources:

```console
nix-shell -p npins curl
pushd $(mktemp -d)
curl https://github.com/fricklerhandwerk/home-damager/blob/main/example.nix > default.nix
npins init --bare
npins add github nix-community home-manager --branch release-24.11
npins add github fricklerhandwerk home-damager --branch main
nix-shell --run switch
```

To uninstall, delete all profile generations created by Home Manager.
On a vanilla system this amounts to:


```bash
rm "${XDG_STATE_HOME:-$HOME/.local/state}"/nix/profiles/{home-manager,profile}*
```

The next garbage collection will remove the dangling store objects.

# Development

Run a NixOS VM test:

```console
nix-build -A test
```

Run the test interactively:

```console
nix-shell --run test-interactive
```
