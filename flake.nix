{
  description = "fastapi-nix-experiment";

  inputs = {
    nixpkgs.url = "https://github.com/NixOS/nixpkgs/archive/nixos-23.05.tar.gz";
    flake-utils.url = "github:numtide/flake-utils";

    # This section will allow us to create a python environment
    # with specific predefined python packages from PyPi
    pypi-deps-db = {
      url = "github:DavHau/pypi-deps-db";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.mach-nix.follows = "mach-nix";
    };
    mach-nix = {
      url = "github:DavHau/mach-nix/3.5.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pypi-deps-db.follows = "pypi-deps-db";
    };
  };

  outputs = { self, nixpkgs, flake-utils, mach-nix, ... }@attr:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };

      # create a custom python environment
      myPython = mach-nix.lib.${system}.mkPython {
        # specify the base version of python you with to use
        python = "python311";

        requirements = ''
          fastapi
          uvicorn
        '';
      };
    in {
      devShell = pkgs.mkShell {
        nativeBuildInputs = [
          # Now you can use your custom python environemt!
          # This should also work for `buildInputs` and so on!
          myPython
        ];
      };

      packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
      packages.x86_64-linux.default = self.packages.x86_64-linux.hello;
    }
  );
}
