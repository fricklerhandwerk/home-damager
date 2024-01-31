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


Check [`example.nix`](./example.nix) for the structure of the entry point to your set of Home Manager configurations.

To use it, get a copy and add remote sources:

```console
nix-shell -p npins wget --run $SHELL
wget https://github.com/fricklerhanderk/home-damager/tree/main/example.nix
npins init --bare
npins add github nixos nixpkgs --branch nixos-23.11
npins add github fricklerhandwerk home-damager
```

# Development

Run an interactive NixOS VM test:

```console
nix-build --run test-interactive
```

When the Python prompt `>>>` appears, enter:

```python
start_all()
```

When the login prompt appears, login with `root`.
Then run:

```console
run-test
```

When the test succeeds, run `poweroff` and then `Ctrl`+`D` to stop the VM.

Due to the impure `fetchTarball` reference used to automatically fetch the right version of Home Manager (the secret sauce to convenience), it's unfortunately impractical to make a hermetic integration test.
