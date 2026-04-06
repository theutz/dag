{ lib, ... }:
let
  dag' = import ./dag.nix { inherit lib; };

  render =
    {
      dag,
      mapEntries ? lib.id,
      separator ? "\n",
    }:
    let
      sortedDag = dag'.topoSort dag;
      renderedDag =
        if sortedDag ? result then
          lib.pipe sortedDag.result [
            (map (lib.getAttr "data"))
            (entries: lib.concatStringsSep separator (map mapEntries entries))
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
