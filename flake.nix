{
  description = "LaTeX environment with custom moderncv";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux"; # Change to your system
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          (pkgs.texliveFull.withPackages (ps: with ps; [ moderncv ]))
          pkgs.nerd-fonts.ubuntu
        ];
      };
    };
}
