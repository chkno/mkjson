{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };
  outputs = { self, nixpkgs, }:
    let

      inherit (builtins) attrNames attrValues foldl';
      inherit (nixpkgs.lib) genAttrs;

      # Work around https://github.com/NixOS/nixpkgs/issues/96405
      composeExtensions = f: g: final: prev:
        let
          fApplied = f final prev;
          prev' = prev // fApplied;
        in fApplied // g final prev';

      for-supported-systems = genAttrs (attrNames
        ((import (nixpkgs + "/pkgs/top-level/release.nix")
          { }).stdenvBootstrapTools));

      packages = for-supported-systems (system: {
        inherit (nixpkgs.legacyPackages."${system}".appendOverlays
          [ self.overlay ])
          mkjson;
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

    in {
      inherit packages;

      overlays = {
        jsonstreams = final: prev: {
          python3 = prev.python3.override {
            packageOverrides = pyfinal: pyprev: {
              jsonstreams =
                pyprev.jsonstreams or (pyfinal.callPackage jsonstreams { });
            };
          };
        };
        mkjson = final: prev: { mkjson = import ./. { pkgs = final; }; };
      };

      overlay =
        foldl' composeExtensions (final: prev: { }) (attrValues self.overlays);

      defaultPackage =
        for-supported-systems (system: packages."${system}".mkjson);

      defaultApp = for-supported-systems (system: {
        type = "app";
        program = "${packages."${system}".mkjson}/bin/mkjson";
      });
    };
}
