{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };
  outputs = { self, nixpkgs, }:
    let

      inherit (builtins) attrNames;
      inherit (nixpkgs.lib) genAttrs;

      for-supported-systems = genAttrs (attrNames
        ((import (nixpkgs + "/pkgs/top-level/release.nix")
          { }).stdenvBootstrapTools));

      packages = for-supported-systems (system: {
        mkjson = import ./. {
          pkgs = nixpkgs.legacyPackages."${system}".appendOverlays
            [ jsonstreamsOverlay ];
        };
      });

      # Pending https://github.com/NixOS/nixpkgs/pull/105819
      jsonstreams = { lib, buildPythonPackage, fetchFromGitHub, pytest, six, }:
        buildPythonPackage rec {
          pname = "jsonstreams";
          version = "0.5.0";

          src = fetchFromGitHub {
            owner = "dcbaker";
            repo = pname;
            rev = version;
            sha256 = "0c85fdqkj5k4b0v0ngx2d9qbmzdsvglh4j9k9h7508bvn7l8fa4b";
          };

          propagatedBuildInputs = [ six ];

          checkInputs = [ pytest ];

          # From tox.ini
          checkPhase = ''
            py.test tests []
            py.test --doctest-modules jsonstreams []
          '';

          meta = with lib; {
            description = "A JSON streaming writer";
            homepage = "https://github.com/dcbaker/jsonstreams";
            license = licenses.mit;
            maintainers = with maintainers; [ chkno ];
          };
        };
      jsonstreamsOverlay = final: prev: {
        python3 = prev.python3.override {
          packageOverrides = pyfinal: pyprev: {
            jsonstreams =
              pyprev.jsonstreams or (pyfinal.callPackage jsonstreams { });
          };
        };
      };

    in {
      inherit packages;

      defaultPackage =
        for-supported-systems (system: packages."${system}".mkjson);

      defaultApp = for-supported-systems (system: {
        type = "app";
        program = "${packages."${system}".mkjson}/bin/mkjson";
      });
    };
}
