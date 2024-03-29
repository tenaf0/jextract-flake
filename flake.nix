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
          rev = "0f87c6cdd5d63a7148deb38e16ed4de1306a4573";
          sha256 = "sha256-Bji7I6LNMs70drGo5+75OClCrxhOsoLV2V7Wdct6494=";
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
