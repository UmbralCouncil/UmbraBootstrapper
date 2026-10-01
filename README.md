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

## Bootstrap UmbraOS

Once the image has network access, run its bootstrap command:

```sh
bs
```

`bs` clones UmbraOS into `/etc/umbra` (or fast-forwards an existing checkout)
and switches to its `umbra-live` configuration. The switch starts the graphical
UmbraOS live session and its special installer. The installer then prepares the
selected target disk, generates its hardware configuration and account
settings, and installs the persistent `umbra-x86_64-linux` system. The
bootstrap disk's existing EFI bootloader stays in place while the live
configuration is active because `umbra-live` deliberately disables
installed-system bootloader changes.

The 4 GiB setting is suitable for the bootstrap image but is not enough to
hold many generations. If the live closure exhausts it during the switch,
expand the containing disk; the root partition and ext4 filesystem grow
automatically at boot.

Useful settings:

- Change `virtualisation.diskSize` in `flake.nix` to set the image capacity in
  MiB.
- Add packages with `environment.systemPackages` in `configuration.nix`.
- Inspect or extend the complete machine configuration through
  `nixosConfigurations.umbra`.
