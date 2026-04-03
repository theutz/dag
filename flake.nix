{
  description = "dag";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = inputs: import ./nix { inherit (inputs.nixpkgs) lib; };
}
