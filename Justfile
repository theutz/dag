help:
  just -l

ci:
  nix-unit ./tests.nix

fmt *args:
  treefmt {{args}}
