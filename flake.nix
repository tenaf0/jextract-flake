{
  description = "A flake file for building jextract";

  inputs.nixpkgs-jdk19.url = github:jerith666/nixpkgs/openjdk-19;

  outputs = { self, nixpkgs, nixpkgs-jdk19, flake-utils }: 

  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      openjdk19 = nixpkgs-jdk19.legacyPackages.${system}.pkgs.openjdk19;

      envVars = ''
          export OPENJDK19=${openjdk19}
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
          rev = "f70e8d2dc7a7d49068c82b5039bb88fd76860dbe";
          sha256 = "sha256-IBR0nG9dQTm4hw5vA+vr1crdvMyTNX9RUryXlrkBJ58=";
        };

        buildInputs = [ pkgs.gradle ];

        buildPhase = envVars + ''

          gradle -Pjdk19_home=$OPENJDK19 -Pllvm_home=$LIBCLANG clean verify
        '';

        installPhase = ''
          cp -r build/jextract $out
        '';
      };
    });
}
