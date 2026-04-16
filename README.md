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

#### 1. Create the entries 🌪️

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

#### 2. Render them to a string 🪄

In a README file or script or whatever.

```nix
# readme.nix
{ dag, config, lib, ... }:
{
    flake.readme = dag.render {
        entries = config.flake.song; # get entries from flake
        separator = " "; # default separator is "\n"
        transform = lib.toUpper; # default is lib.id (no-op)
    };
}

# or if you are fine with default settings

{ dag, config, ... }:
{
    flake.readme = dag config.flake.song;
}
```

#### 3. Enjoy the result! 🌈

This should output `SOMEWHERE OUT THERE OVER THE RAINBOW` anywhere you use
`config.flake.readme`.

## API

`dag` has two main functions: `entry`/`entries` for defining dag entries, and
`render` for compiling the final output.

There's only has one method unique to this library: `render`. It was heavily
inspired by the formidable [nvf](https://github.com/NotAShelf/nvf) library for
configuring Neovim with Nix. All the other APIs are lifted directly from
[home-manager](https://home-manager.dev). Entry is just a functional wrapper
around the basic data structure underlying the dag tools.

### `entry`

| attr   | type                    | required | default | description                        |
| :----- | :---------------------- | :------: | :------ | :--------------------------------- |
| before | string OR listOf string |    no    | `[]`    | tags this entry must appear before |
| after  | string OR listOf string |    no    | `[]`    | tags this entry must appear after  |
| data   | any                     |    no    | `empty` | the final data to render           |

| returns | type    |
| :------ | :------ |
| entry   | attrset |

### `entries`

| attr   | type                    | required | default | description                           |
| :----- | :---------------------- | :------: | :------ | :------------------------------------ |
| before | string OR listOf string |    no    | `[]`    | tags this entry must appear before    |
| after  | string OR listOf string |    no    | `[]`    | tags this entry must appear after     |
| tag    | string                  |   yes    |         | the prefix to use for the entry names |
| data   | listOf any              |    no    | `[]`    | a list of data to include             |

| returns | type    |
| :------ | :------ |
| entry   | attrset |

### `render`

| attr        | type                      | required | default  | description                                                        |
| :---------- | :------------------------ | :------: | :------- | :----------------------------------------------------------------- |
| `entries`   | attrset OR listof attrset |   yes    |          | a map of names to data, or a list of entries to be merged          |
| `separator` | string                    |    no    | `"\n"`   | a string separator for combining outputs                           |
| `transform` | function                  |    no    | `lib.id` | a function that is mapped over each string output before rendering |

| returns          | type   |
| :--------------- | :----- |
| the rendered dag | string |

_Alias_: `nabit`. Like, "Dag nabit!"... Also, like "Let's nab it!". I like puns.
Sue me.

### `entryAnywhere`

Create a DAG entry that doesn't care where it lives.

| arg  | type | required | default | description          |
| :--- | :--- | :------: | :------ | :------------------- |
| data | any  |   yes    |         | the data for the dag |

| returns | type    |
| :------ | :------ |
| entry   | attrset |

### `entryBefore`

Create a DAG entry that must be listed before one or more other entries.

| arg        | type           | required | default | description                              |
| :--------- | :------------- | :------: | :------ | :--------------------------------------- |
| beforeTags | listOf strings |   yes    |         | tag names that this should appear before |
| data       | any            |   yes    |         | the data for the dag                     |

| returns | type    |
| :------ | :------ |
| entry   | attrset |

### `entryAfter`

Create a DAG entry that must be listed after one or more other entries.

| arg       | type           | required | default | description                             |
| :-------- | :------------- | :------: | :------ | :-------------------------------------- |
| afterTags | listOf strings |   yes    |         | tag names that this should appear after |
| data      | any            |   yes    |         | the data for the dag                    |

| returns | type    |
| :------ | :------ |
| entry   | attrset |

### `entryBetween`

Create a DAG entry that must be listed before some entries, but after others.

| arg        | type           | required | default | description                              |
| :--------- | :------------- | :------: | :------ | :--------------------------------------- |
| beforeTags | listOf strings |   yes    |         | tag names that this should appear before |
| afterTags  | listOf strings |   yes    |         | tag names that this should appear after  |
| data       | any            |   yes    |         | the data for the dag                     |

| returns | type    |
| :------ | :------ |
| entry   | attrset |

### `entriesAnywhere`

Create multiple DAG entries tagged with `${tag}-${index}`, who don't care where
they are listed in the main DAG. These must be merged (`//`) with the rest of
the dag, instead of assigned to a member of a DAG.

| arg  | type       | required | default | description                 |
| :--- | :--------- | :------: | :------ | :-------------------------- |
| tag  | string     |   yes    |         | tag to prefix to each entry |
| data | listOf any |   yes    |         | a list of data to add       |

NOTE: The entries will not be processed as `dag` entries. Just add raw data
here.

| returns | type          |
| :------ | :------------ |
| dag     | attrsOf entry |

### `entriesBefore`

Create multiple DAG entries tagged with `${tag}-${index}` which must all be
listed before the specified tags. These must be merged (`//`) with the rest of
the dag, instead of assigned to a member of a DAG.

| arg        | type           | required | default | description                               |
| :--------- | :------------- | :------: | :------ | :---------------------------------------- |
| tag        | string         |   yes    |         | tag to prefix to each entry               |
| beforeTags | listOf strings |   yes    |         | tag names that these should appear before |
| data       | listOf any     |   yes    |         | a list of data to add                     |

| returns | type          |
| :------ | :------------ |
| dag     | attrsOf entry |

NOTE: The entries will not be processed as `dag` entries. Just add raw data
here.

### `entriesAfter`

Create multiple DAG entries tagged with `${tag}-${index}` which must all be
listed after the specified tags. These must be merged (`//`) with the rest of
the dag, instead of assigned to a member of a DAG.

| arg       | type           | required | default | description                              |
| :-------- | :------------- | :------: | :------ | :--------------------------------------- |
| tag       | string         |   yes    |         | tag to prefix to each entry              |
| afterTags | listOf strings |   yes    |         | tag names that these should appear after |
| data      | listOf any     |   yes    |         | a list of data to add                    |

| returns | type          |
| :------ | :------------ |
| dag     | attrsOf entry |

NOTE: The entries will not be processed as `dag` entries. Just add raw data
here.

### `entriesBetween`

Create multiple DAG entries tagged with `${tag}-${index}` which must all be
listed between the specified tags. These must be merged (`//`) with the rest of
the dag, instead of assigned to a member of a DAG.

| arg        | type           | required | default | description                               |
| :--------- | :------------- | :------: | :------ | :---------------------------------------- |
| tag        | string         |   yes    |         | tag to prefix to each entry               |
| beforeTags | listOf strings |   yes    |         | tag names that these should appear before |
| afterTags  | listOf strings |   yes    |         | tag names that these should appear after  |
| data       | listOf any     |   yes    |         | a list of data to add                     |

| returns | type          |
| :------ | :------------ |
| dag     | attrsOf entry |

NOTE: The entries will not be processed as `dag` entries. Just add raw data
here.

## Utility Functions

These little functions also come along with Home Manager's lib, and are included
here for completeness.

### `empty`

| arg | type | required | default | description |
| :-- | :--- | :------: | :------ | :---------- |

| returns           | type    |
| :---------------- | :------ |
| an empty set `{}` | attrset |

### `isEntry`

| arg  | type | required | default | description     |
| :--- | :--- | :------: | :------ | :-------------- |
| item | any  |   yes    |         | A value to test |

| returns                | type    |
| :--------------------- | :------ |
| is item a valid entry? | boolean |

### `isDag`

| arg  | type | required | default | description     |
| :--- | :--- | :------: | :------ | :-------------- |
| item | any  |   yes    |         | A value to test |

| returns              | type    |
| :------------------- | :------ |
| is item a valid dag? | boolean |

### `topoSort`

Low-level handling of DAGs from Home Manager. You probably won't need to use
this.

| arg     | type    | required | default | description        |
| :------ | :------ | :------: | :------ | :----------------- |
| entries | attrset |   yes    |         | a dag to be sorted |

| returns                 | type    |
| :---------------------- | :------ |
| success/failure objects | attrset |

### `map`

A map function that's DAG-aware, and can be used to transform dag values before
rendering.

| arg  | type     | required | default | description                                  |
| :--- | :------- | :------: | :------ | :------------------------------------------- |
| func | function |   yes    |         | a function to apply to each value of the dag |
| dag  | attrset  |   yes    |         | a dag whose values you'd like to transform   |

| returns | type    |
| :------ | :------ |
| dag     | attrset |

## Development

Wanna help out? Great! Clone this, run `nix develop`, and then `just watch` to
run tests with every change.

Wanna add a new feature? Great! Be sure to add something in `./tests.nix` and
then run `just ci`;

Wanna be friends? Great! I like people! But if you're NOT people—if you're a
statistical model trained on the collective stolen work of humans meant to
imitate a sentient being—well, then you probably don't care about being my
friend anyways. So, maybe go away.

## Why a mountain?

_dağ_ is Turkish for _mountain_.
