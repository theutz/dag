{ lib, ... }:
let
  dag' = import ./dag.nix { inherit lib; };
  types = import ./types.nix { inherit lib; };

  render =
    {
      entries,
      transform ? lib.id,
      separator ? "\n",
    }:
    let
      sortedDag = lib.pipe entries [
        lib.toList
        lib.mergeAttrsList
        dag'.topoSort
      ];
      renderedDag =
        if sortedDag ? result then
          lib.pipe sortedDag.result [
            (lib.map (lib.getAttr "data"))
            (data: lib.concatStringsSep separator (lib.map transform data))
          ]
        else
          abort ("Dependency cycle in activation script: " + builtins.toJSON sortedDag);
    in
    renderedDag;

  api =
    dag'
    // types
    // {
      inherit render; # serious
      nabit = render; # cute
      of = types.dagOf;
    };
in
api
