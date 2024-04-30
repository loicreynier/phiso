# φso

A LuaLaTeX package based on
the [`unicode-math`][unicode_math] and [`derivative`][derivative] packages
providing commands to write the equations of physics
respecting the [ISO-80000][iso] standard.

## About

φso or `phiso` is a personal package
that I use to typeset equations in documents and presentations.
Most of the commands are related to fluid mechanics,
however the package might expand and be useful to others.

## Requirements

As well as running LuaLaTex for unicode support,
the following package are required:

- [`derivative`][derivative]
- [`unicode-math`][unicode_math]

## Package options

The package offers several options for tailoring its behavior.
These options can be enabled using the following:

```latex
\usepackage[<option1>,<option2>]{phiso}
```

Below is the enumeration of these options:

- `mathtools`: load the `mathtools` package prior to `unicode-math`
- `nablaregular`: use regular symbol (not bold) for nabla

## Installation

As a personal package,
φso is not included in TeX Live or any other distribution.
To use it,
you have the option to download and copy the `phiso.sty` file
into your LaTeX document's source folder,
or install it in your `$TEXMFHOME` directory with the following command:

```shell
wget https://github.com/loicreynier/phiso/blob/main/phiso.sty \
     -O "$TEXMFHOME/phiso.sty"
```

After installation,
you can simply load it like any other package with `\usepackage{phiso}`.

### Nix TeX Live custom package

For Nix users,
the flake provides a TeX Live package (`scheme-full`) available with φso
already installed.
Here's an example of a flake that provides an environment
with this version of Tex Live:

```nix
{
  description = "LaTeX document";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
    phiso.url = "github:loicreynier/phiso";
    phiso.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    phiso,
  }: let
    supportedSystems = ["x86_64-linux"];
  in
    flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          phiso.packages.${pkgs.system}.texlive-phiso
        ];
      };
    });
}
```

You can also build your own Tex Live package by adding φso
as a package :

```nix
texliveCustom = with pkgs;
  (texlive.combine {
    inherit (texlive) scheme-full; # Select your Tex Live scheme
    pkgFilter = pkg:
      lib.elem pkg.tlType [
        "run"
        "bin"
      ];
    phiso = {
      pkgs = [phiso.packages.${pkgs.system}.default];
    };
  })
```

[derivative]: https://www.ctan.org/pkg/derivative
[iso]: https://en.wikipedia.org/wiki/ISO/IEC_80000
[unicode_math]: https://github.com/wspr/unicode-math
