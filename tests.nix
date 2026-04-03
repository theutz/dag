# RUN WITH: nix-unit ./tests.nix
{
  pkgs ? import <nixpkgs> { },
}:
let
  dag = import ./. { inherit (pkgs) lib; };
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
}
