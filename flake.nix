{
  description = "State of Nix at European Commission";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    theme-ec.url = "git+https://code.europa.eu/pol/european-commission-latex-beamer-theme/";
  };

  outputs = { self, nixpkgs, flake-utils, theme-ec, ... }@inputs:
    with flake-utils.lib; eachSystem allSystems (system:
      let
        version = self.shortRev or self.lastModifiedDate;

        pkgs = import nixpkgs {
          inherit system;
        };

        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-full latex-bin latexmk;
          theme-ec = {
              pkgs = [ theme-ec.packages."${system}".theme-ec ];
          };
        };

        documentProperties = {
          name = "nix-at-ec-presentation";
          inputs = [
            tex
            pkgs.coreutils
            pkgs.gnumake
            # pkgs.openjdk
            # pkgs.plantuml
            # pkgs.pandoc
            # pkgs.plantuml
            # pkgs.nixpkgs-fmt
            # pkgs.nixfmt
            # pkgs.pympress
          ];
        };

        documentDrv = pkgs.stdenvNoCC.mkDerivation {
          name = documentProperties.name + "-" + version;
          src = self;
          buildInputs = documentProperties.inputs;
          configurePhase = ''
            runHook preConfigure
            substituteInPlace "src/nix-at-ec/version.tex" \
              --replace "dev" "${version}"
            runHook postConfigure
          '';
          installPhase = ''
            runHook preInstall
            cp build/nix-at-ec.pdf $out
            runHook postInstall
          '';
        };
      in
      rec {
        # Nix shell / nix build
        packages.default = documentDrv;

        # Nix develop
        devShells.default = pkgs.mkShellNoCC {
          name = documentProperties.name;
          buildInputs = documentProperties.inputs;
        };
      });
}
