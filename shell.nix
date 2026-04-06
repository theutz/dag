{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  buildInputs = [
    pkgs.just
    pkgs.nix-unit
    pkgs.treefmt
    pkgs.nixfmt
    pkgs.watchexec
  ];
}
