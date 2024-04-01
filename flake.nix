{
  description = "A flake file for building jextract";

  outputs = { self, nixpkgs, flake-utils }: 

  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      openjdk22 = pkgs.openjdk22;

      envVars = ''
          export OPENJDK22=${openjdk22}
          export LIBCLANG=${pkgs.llvmPackages_14.libclang.lib}
        '';
    in {
      devShell = pkgs.mkShell {
        buildInputs = [ openjdk22 ];
        shellHook = envVars;
      };

      defaultPackage = pkgs.stdenv.mkDerivation {
        name = "jextract";
        src = pkgs.fetchFromGitHub {
          owner = "openjdk";
          repo = "jextract";
          rev = "b9ec8879cff052b463237fdd76382b3a5cd8ff2b";
          sha256 = "sha256-+4AM8pzXPIO/CS3+Rd/jJf2xDvAo7K7FRyNE8rXvk5U=";
        };

        buildInputs = [ (pkgs.gradle_8.override { java = pkgs.openjdk21; }) ];

        buildPhase = envVars + ''

          gradle -Pjdk22_home=$OPENJDK22 -Pllvm_home=$LIBCLANG clean verify
        '';

        installPhase = ''
          cp -r build/jextract $out
        '';
      };
    });
}
