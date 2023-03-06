{
  description = "llama running on cpu in int8 mode";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    mach-nix.url = "github:hx507/mach-nix";
    #mach-nix.url = "path:./mach-nix";
  };

  outputs = { self, nixpkgs, mach-nix, flake-utils, ... }:
    let pythonVersion = "python39";
    in flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        mach = mach-nix.lib.${system};

        pythonApp = mach.buildPythonApplication ./.;
        pythonAppEnv = mach.mkPython {
          python = pythonVersion;
          requirements = builtins.readFile ./requirements.txt;
          providers = {
            # The default for all packages which are not specified explicitly
            #_default = "nixpkgs,wheel,conda,sdist";
            _default = "nixpkgs,wheel,sdist";
          };
        };
      in rec {
        packages = {
          pythonPkg = pythonApp;
          default = packages.pythonPkg;
        };

        apps.default = {
          type = "app";
          program = "${packages.pythonPkg}/bin/main";
        };

        devShells.default = pkgs.mkShellNoCC {
          packages = [ pythonAppEnv ];

          shellHook = ''
            export PYTHONPATH="${pythonAppEnv}/bin/python"
          '';
        };
      });
}
