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

  entry.before.test-string-deps = {
    expr = dag.render {
      entries = {
        first = dag.entry { data = "foo"; };
        second = dag.entry {
          before = "first";
          data = "bar";
        };
      };
    };
    expected = "bar\nfoo";
  };

  entry.before.test-list-deps = {
    expr = dag.render {
      entries = {
        first = dag.entry { data = "foo"; };
        second = dag.entry {
          before = "first";
          data = "bar";
        };
      };
    };
    expected = "bar\nfoo";
  };

  entry.before.test-between = {
    expr = dag.render {
      entries = {
        third = dag.entry {
          data = "baz";
        };
        second = dag.entry {
          before = [ "third" ];
          after = "first";
          data = "bar";
        };
        first = dag.entry { data = "foo"; };
      };
    };
    expected = "foo\nbar\nbaz";
  };

  entry.after.test-string-deps = {
    expr = dag.render {
      entries = {
        second = dag.entry {
          after = "first";
          data = "bar";
        };
        first = dag.entry { data = "foo"; };
      };
    };
    expected = "foo\nbar";
  };

  entry.after.test-list-deps = {
    expr = dag.render {
      entries = {
        second = dag.entry {
          after = [ "first" ];
          data = "bar";
        };
        first = dag.entry { data = "foo"; };
      };
    };
    expected = "foo\nbar";
  };

  entries.before.test-str-deps = {
    expr = dag.render {
      entries = [
        (dag.entries {
          tag = "second";
          data = [ "bar" ];
        })
        {
          first = dag.entry {
            before = "second-0";
            data = "foo";
          };
          third = dag.entry {
            after = [ "second-0" ];
            data = "baz";
          };
        }
      ];
    };
    expected = "foo\nbar\nbaz";
  };
}
