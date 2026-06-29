{
  description = "ChromaDB semantic search demo — Práctico 06 BD Vectoriales";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    nixpkgsFor = forAllSystems (system: nixpkgs.legacyPackages.${system});
  in {
    devShells = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          python312
          python312Packages.pip
          python312Packages.chromadb
        ];

        shellHook = ''
          echo "🐍 Entorno Python + ChromaDB listo"
          echo "   Ejecutá: python main.py"
        '';
      };
    });
  };
}
