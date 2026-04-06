# RUN WITH: nix-unit ./tests.nix
{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) lib;
  dag = import ./. { inherit lib; };
in
{
  math-works.test-mult = {
    expr = 11 * 2;
    expected = 22;
  };

  smoke.test-render-exist = {
    expr = dag ? render;
    expected = true;
  };

  render.test-outputs-data = {
    expr = dag.render {
      dag.greeting = dag.entryAnywhere "# Hello";
      dag.follow-up = dag.entryAfter [ "greeting" ] "Happy to be here.";
    };
    expected = "# Hello\nHappy to be here.";
  };

  render.test-different-separator = {
    expr = dag.render {
      dag.greeting = dag.entryAnywhere "# Hello";
      dag.follow-up = dag.entryAfter [ "greeting" ] "Happy to be here.";
      separator = "! ";
    };
    expected = "# Hello! Happy to be here.";
  };

  render.test-hm-map-helper = {
    expr = dag.render {
      dag.greeting = dag.entryAnywhere "# Hello";
      dag.follow-up = dag.entryAfter [ "greeting" ] "Happy to be here.";
      mapEntries = lib.toUpper;
    };
    expected = "# HELLO\nHAPPY TO BE HERE.";
  };
}
