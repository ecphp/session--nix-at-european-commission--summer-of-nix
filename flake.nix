{
  description = "State of Nix at European Commission";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    theme-ec.url = "git+https://code.europa.eu/pol/european-commission-latex-beamer-theme/";
    ec-fonts.url = "git+https://code.europa.eu/pol/ec-fonts/";
    ci-detector.url = "github:loophp/ci-detector";
  };

  outputs = { self, nixpkgs, flake-utils, theme-ec, ec-fonts, ci-detector, ... }@inputs:
    with flake-utils.lib; eachSystem allSystems (system:
      let
        version = self.shortRev or self.lastModifiedDate;

        pkgs = import nixpkgs {
          inherit system;

          overlays = [
            theme-ec.overlays.default
            ec-fonts.overlays.default
          ];
        };

        tex = pkgs.texlive.combine {
            inherit (pkgs.texlive) scheme-full latex-bin latexmk;

            latex-theme-ec = {
                pkgs = [ pkgs.latex-theme-ec pkgs.ec-square-sans-lualatex ];
            };
        };

        tex-for-ci = pkgs.texlive.combine {
            inherit (pkgs.texlive) scheme-full latex-bin latexmk;

            latex-theme-ec = {
                pkgs = [ pkgs.latex-theme-ec ];
            };
        };

        documentDerivation = pkgs.stdenvNoCC.mkDerivation {
          name = "nix-at-ec--summer-of-nix-2022";

          src = self;

          buildInputs = [
            pkgs.coreutils
            pkgs.gnumake
          ];

          configurePhase = ''
            runHook preConfigure
            substituteInPlace "src/nix-at-ec/version.tex" \
              --replace "dev" "${version}"
            runHook postConfigure
          '';
          installPhase = ''
            runHook preInstall

            install -m644 -D build/*.pdf --target $out/

            runHook postInstall
          '';
        };
      in
      {
        # Nix shell / nix build
        packages.default = if ci-detector.lib.inCI then
            (documentDerivation.overrideAttrs (oldAttrs: {
                buildInputs = [ oldAttrs.buildInputs ] ++ [ tex-for-ci ];
            }))
        else
            (documentDerivation.overrideAttrs (oldAttrs: {
                buildInputs = [ oldAttrs.buildInputs ] ++ [ tex ];
            }));

        # Nix develop
        devShells.default = pkgs.mkShellNoCC {
          name = "latex-devshell";
          buildInputs = documentDerivation.buildInputs ++ [ tex ];
        };
      });
}
