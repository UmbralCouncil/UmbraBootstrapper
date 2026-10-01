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

            virtualisation.diskSize = 4096;
          }
        ];
      };

      packages.${system}.default =
        self.nixosConfigurations.umbra.config.system.build.image;

      formatter.${system} = pkgs.nixfmt-tree;
    };
}
