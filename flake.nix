{
  description = "dag";

  inputs = {
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
  };

  outputs = inputs: import ./nix { inherit (inputs.nixpkgs-lib) lib; };
}
