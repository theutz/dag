{ lib, ... }:
let
  dag' = import ./dag.nix { inherit lib; };

  render =
    {
      entries,
      transform ? lib.id,
      separator ? "\n",
    }:
    let
      sortedDag = dag'.topoSort entries;
      renderedDag =
        if sortedDag ? result then
          lib.pipe sortedDag.result [
            (map (lib.getAttr "data"))
            (entries: lib.concatStringsSep separator (map transform entries))
          ]
        else
          abort ("Dependency cycle in activation script: " + builtins.toJSON sortedDag);
    in
    renderedDag;

  api = dag' // {
    inherit render; # serious
    nabit = render; # cute
  };
in
api
