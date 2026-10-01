{ modulesPath, pkgs, ... }:
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
  ];

  networking = {
    hostName = "umbra";
    useDHCP = true;
  };

  # Bootstrap environment: log directly into root on the local console.
  services.getty.autologinUser = "root";

  users.users.root = {
    initialPassword = "";
    openssh.authorizedKeys.keys = [ ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  environment.systemPackages = with pkgs; [
    git
    gptfdisk
    util-linux
    e2fsprogs
    curl
  ];

  environment.shellAliases.umbra-install = "/etc/umbra/install";

  environment.etc."umbra/install" = {
    mode = "0755";
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail

      REPO="https://github.com/UmbralCouncil/UmbraOS.git"
      DIR="/root/UmbraOS"

      echo "=== Umbra Bootstrap ==="

      if [ ! -d "$DIR/.git" ]; then
        ${pkgs.git}/bin/git clone "$REPO" "$DIR"
      else
        ${pkgs.git}/bin/git -C "$DIR" pull --ff-only
      fi

      echo "=== Configuring Umbra Installer ==="

      ${pkgs.nixos-rebuild}/bin/nixos-rebuild boot \
        --flake "$DIR#umbra-live"

      echo
      echo "Umbra installer configured."
      echo "Rebooting..."

      reboot
    '';
  };

  boot = {
    growPartition = true;
    initrd.systemd.enable = true;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = false;
    };
  };

  nix.settings = {
    auto-optimise-store = true;

    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  system.stateVersion = "25.11";
}
