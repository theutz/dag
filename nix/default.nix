{ lib, ... }:
let
  dag' = import ./dag.nix { inherit lib; };

  render =
    {
      dag,
      mapper ? lib.id,
      separator ? "\n",
    }:
    let
      sortedDag = dag'.topoSort dag;
      renderedDag =
        if sortedDag ? result then
          lib.concatStringsSep separator (map mapper sortedDag.result)
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
