{
  description = "phiso LaTeX package";

  inputs = {
    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    pre-commit-hooks,
  }: let
    supportedSystems = ["x86_64-linux"];
  in
    flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in rec {
      checks = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = with pkgs; {
            alejandra.enable = true;
            commitizen = {
              enable = true;
              entry = "${pkgs.commitizen}/bin/cz check --commit-msg-file";
              stages = ["commit-msg"];
            };
            editorconfig-checker = {
              enable = true;
              entry = "${pkgs.editorconfig-checker}/bin/editorconfig-checker";
              types = ["file"];
            };
            prettier.enable = true;
            statix.enable = true;
          };
        };
      };

      devShells.default = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };
    });
}
