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
          rev = "61c3e33b1f622ce1661d1525a07c67d273461de1";
          sha256 = "sha256-PRqu+Eo6byBg8Y+quIcRwwAWEzV58tMazIX5gzWBEcw=";
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
