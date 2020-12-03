{ pkgs ? import <nixpkgs> { } }:
pkgs.python3Packages.callPackage
({ lib, buildPythonPackage, jsonstreams, more-itertools, }:
  buildPythonPackage rec {
    pname = "mkjson";
    version = "0.0.1";
    src = lib.cleanSource ./.;
    propagatedBuildInputs = [ jsonstreams more-itertools ];
    meta = with lib; {
      description = "A shell-friendly JSON encoder";
      license = licenses.mit;
      maintainers = with maintainers; [ chkno ];
    };
  }) { }
