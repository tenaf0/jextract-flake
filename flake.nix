{
  description = "A flake file for building jextract";

  inputs = {
    nixpkgs-jdk20.url = "github:tenaf0/nixpkgs/jdk20";
  };

  outputs = { self, nixpkgs, flake-utils, nixpkgs-jdk20 }: 

  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      openjdk20 = nixpkgs-jdk20.legacyPackages.${system}.openjdk20;

      envVars = ''
          export OPENJDK20=${openjdk20}
          export LIBCLANG=${pkgs.libclang.lib}
        '';
    in {
      devShell = pkgs.mkShell {
        buildInputs = [ pkgs.openjdk17 ];
        shellHook = envVars;
      };

      defaultPackage = pkgs.stdenv.mkDerivation {
        name = "jextract";
        src = pkgs.fetchFromGitHub {
          owner = "openjdk";
          repo = "jextract";
          rev = "cf3afe9ca71592c8ebb32f219707285dd1d5b28a";
          sha256 = "sha256-8qRD1Xg39vxtFAdguD8XvkQ8u7YzFU55MhyyJozVffo=";
        };

        buildInputs = [ pkgs.gradle ];

        buildPhase = envVars + ''

          gradle -Pjdk20_home=$OPENJDK20 -Pllvm_home=$LIBCLANG clean verify
        '';

        installPhase = ''
          cp -r build/jextract $out
        '';
      };
    });
}
