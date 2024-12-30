{
  description = "phiso LaTeX package";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    git-hooks,
  }: let
    supportedSystems = ["x86_64-linux"];
  in
    flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      checks = {
        pre-commit-check = git-hooks.lib.${system}.run {
          src = ./.;

          hooks = {
            alejandra.enable = true;
            commitizen.enable = true;
            editorconfig-checker.enable = true;
            prettier = {
              enable = true;
              excludes = ["flake.lock"];
            };
            statix.enable = true;
            typos.enable = true;
          };
        };
      };

      packages = rec {
        phiso = pkgs.stdenv.mkDerivation rec {
          name = "phiso";
          pname = name;
          src = ./.;
          dontConfigure = true;
          installPhase = ''
            mkdir -p $out/tex/latex
            cp phiso.sty $out/tex/latex
          '';
          tlType = "run";
        };
        texlive-phiso = with pkgs;
          texlive.combine {
            inherit (texlive) scheme-full;
            pkgFilter = pkg:
              lib.elem pkg.tlType [
                "run"
                "bin"
              ];
            phiso = {
              pkgs = [phiso];
            };
          };
        default = texlive-phiso;
      };

      devShells = {
        default = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };
        tests = pkgs.mkShell {
          packages = [
            self.packages.${system}.texlive-phiso
          ];
        };
      };
    });
}
