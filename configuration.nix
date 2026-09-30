{ modulesPath, ... }:
{
  imports = [ "${modulesPath}/profiles/minimal.nix" ];

  networking = {
    hostName = "umbra";
    useDHCP = true;
  };

  # Keep the image useful from both a VM console and over the network. Root
  # has no password, so SSH accepts keys only; add keys below when needed.
  services.getty.autologinUser = "root";
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
  users.users.root.openssh.authorizedKeys.keys = [ ];

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
