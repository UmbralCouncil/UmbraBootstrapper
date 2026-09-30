# Umbra bootstrap image

This flake builds a small, bootable x86-64 NixOS raw disk image. It uses GPT,
an EFI system partition, and a persistent ext4 root filesystem. The root
partition grows to fill the image on first boot.

```sh
nix build
ls -lh result/umbra.img
```

Write it to a disk with a tool such as `dd` or import it as a raw disk in a
UEFI-enabled VM. The image is sparse; use a sparse-aware copy when moving it:

```sh
cp --sparse=always result/umbra.img /path/to/umbra.img
```

The VM console automatically logs in as `root`. SSH is enabled with password
authentication disabled. Add an SSH public key to
`users.users.root.openssh.authorizedKeys.keys` in `configuration.nix` before
building if remote login is needed.

Useful settings:

- Change `virtualisation.diskSize` in `flake.nix` to set the image capacity in
  MiB.
- Add packages with `environment.systemPackages` in `configuration.nix`.
- Inspect or extend the complete machine configuration through
  `nixosConfigurations.umbra`.
