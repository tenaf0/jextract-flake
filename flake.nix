{
  description = "A flake file for building jextract";

  outputs = { self, nixpkgs, flake-utils }: 

  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      openjdk21 = pkgs.openjdk21;

      envVars = ''
          export OPENJDK21=${openjdk21}
          export LIBCLANG=${pkgs.libclang.lib}
        '';
    in {
      devShell = pkgs.mkShell {
        buildInputs = [ pkgs.openjdk21 ];
        shellHook = envVars;
      };

      defaultPackage = pkgs.stdenv.mkDerivation {
        name = "jextract";
        src = pkgs.fetchFromGitHub {
          owner = "openjdk";
          repo = "jextract";
          rev = "e961434163ea5c53bbeee9fed1ecf819811ca962";
          sha256 = "sha256-GIpkBVfvZNav3a7i1e9lioS1C6V4C9K9oELt8Zom3v0=";
        };

        buildInputs = [ (pkgs.gradle_8.override { java = openjdk21; }) ];

        buildPhase = envVars + ''

          gradle -Pjdk21_home=$OPENJDK21 -Pllvm_home=$LIBCLANG clean verify
        '';

        installPhase = ''
          cp -r build/jextract $out
        '';
      };
    });
}
