# 🏔️ dag

A lightweight implementation of [home-manager's](https://home-manager.dev)
directed acyclic graph (DAG) helpers.

## Why?

Because Home Manager nailed it, IMO.

And having a single, familiar paradigm for writing structured information spread
across a large flake seemed useful. Especially with the ascendency of
[flake.parts](https://flake.parts), the advent of the
[dendritic pattern](https://github.com/mightyiam/dendritic), and the AOP of
[den](https://den.oeiuwq.com).

![d'ya like dags?](./assets/dags.gif)

## Installation

### Flake

dag is a zero-dependency library, so it needs your version of `nixpkgs` to
borrow from the Nix standard library.

```nix
# flake.nix
{
    inputs = {
        nixpkgs.url = "github:nixos/nixpgks";
        dag.url = "github:theutz/dag";
    };

    outputs = inputs: let
      dag = inputs.dag.lib { inherit (inputs.nixpkgs) lib; };
    in
    {
      # use dag API
    };
}
```

### Flake Parts and/or Den

If you want the `dag` library to be available in the top-level attrset for each
flake-part, do something like this:

```nix
# flake.nix
{
    inputs = {
        nixpkgs.url = "github:nixos/nixpgks";
        flake-parts.url = "github:hercules-ci/flake-parts";
        dag.url = "github:theutz/dag";
    };

    outputs = inputs@{ nixpkgs, flake-parts, dag, ...}:
        flake-parts.lib.mkFlake { inherit inputs; }
        {
            _module.args.dag = inputs.dag.lib { inherit (nixpkgs) lib; };
        };
}
```

## Usage

For the following examples, we'll assume you're using Flake Parts, and have
access to the `config.flake` freeform attribute.

### Rendering a DAG

#### 1. Create the entries

```nix
# somewhere.nix
{ dag, ... }:
{
    flake.song.somewhere = dag.entryBefore ["out"] "Somewhere";
}

# out.nix
{ dag, ... }:
{
    flake.song.out = dag.entryAnywhere "out";
}

# there.nix
{ dag, ... }:
{
    flake.song.there = dag.entryBetween ["otr-0"] ["out"] "there";
}

# over-the-rainbow.nix
{ dag, ... }:
{
    flake.song = dag.entriesAnywhere "otr" ["over" "the" "rainbow"];
}
```

#### 2. Render them to a string

In a README file or script or whatever.

```nix
# readme.nix
{ dag, config, lib, ... }:
{
    flake.readme = dag.render {
        entries = config.flake.song; # get entries from flake
        separator = " "; # default separator is "\n"
        transform = lib.toUpper
    };
}
```

#### 3. Enjoy the result!

This should output `SOMEWHERE OUT THERE OVER THE RAINBOW` anywhere you use
`config.flake.readme`.

## Why a mountain?

_dağ_ is Turkish for _mountain_.
