{
  description = "A tiny, persistent NixOS disk image";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.umbra = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          "${nixpkgs}/nixos/modules/virtualisation/disk-image.nix"
          ./configuration.nix
          {
            image = {
              baseName = "umbra";
              format = "raw";
              efiSupport = true;
            };

            # The image builder creates a sparse disk and grows the ext4
            # filesystem to fill it on first boot.
            virtualisation.diskSize = 2048;
          }
        ];
      };

      packages.${system}.default =
        self.nixosConfigurations.umbra.config.system.build.image;

      formatter.${system} = pkgs.nixfmt-tree;
    };
}
