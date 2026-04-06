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

  render.test-outputs-entries = {
    expr = dag.render {
      entries = {
        greeting = dag.entryAnywhere "# Hello";
        follow-up = dag.entryAfter [ "greeting" ] "Happy to be here.";
      };
    };
    expected = "# Hello\nHappy to be here.";
  };

  render.test-separator = {
    expr = dag.render {
      entries = {
        greeting = dag.entryAnywhere "# Hello";
        follow-up = dag.entryAfter [ "greeting" ] "Happy to be here.";
      };
      separator = "! ";
    };
    expected = "# Hello! Happy to be here.";
  };

  render.test-transform = {
    expr = dag.render {
      entries = {
        greeting = dag.entryAnywhere "# Hello";
        follow-up = dag.entryAfter [ "greeting" ] "Happy to be here.";
      };
      transform = lib.toUpper;
    };
    expected = "# HELLO\nHAPPY TO BE HERE.";
  };

  nabit.test-identity =
    let
      thing = {
        greeting = dag.entryAnywhere "# Hello";
        follow-up = dag.entryAfter [ "greeting" ] "Happy to be here.";
      };
    in
    {
      expr = dag.nabit { entries = thing; };
      expected = dag.render { entries = thing; };
    };

  readme.test-render = {
    expr = dag.render {
      entries = {
        out = dag.entryAnywhere "out";
        somewhere = dag.entryBefore [ "out" ] "Somewhere";
        there =
          dag.entryBetween
            [ "otr-0" ]
            [
              "out"
            ]
            "there";
      }
      // (dag.entriesAnywhere "otr" [
        "over"
        "the"
        "rainbow"
      ]);
      separator = " ";
    };
    expected = "Somewhere out there over the rainbow";
  };
}
