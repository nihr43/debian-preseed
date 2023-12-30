{ nixpkgs ? import <nixpkgs> {  } }:

let
  pkgs =  with nixpkgs; [
    libarchive
    cdrtools
    cdrkit
    syslinux
    xorriso
  ];

in
  nixpkgs.stdenv.mkDerivation {
    name = "env";
    buildInputs = pkgs;
  }
