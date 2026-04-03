# RUN WITH: nix-unit ./tests.nix
let
  dag = import ./.;
in
{
  math-works.test-mult = {
    expr = 11 * 2;
    expected = 22;
  };
}
