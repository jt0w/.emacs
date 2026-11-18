{
  description = "Emacs configuration with emacs-overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = {
    nixpkgs,
    emacs-overlay,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [emacs-overlay.overlays.default];
    };

    myEmacs = pkgs.emacsWithPackagesFromUsePackage {
      package = pkgs.emacs-pgtk;
      config = ./Config.org;
      defaultInitFile = true;
      alwaysEnsure = true;
      alwaysTangle = true;

      extraEmacsPackages = epkgs: [
        epkgs.treesit-grammars.with-all-grammars
        epkgs.use-package
        epkgs.general
        epkgs.elpaDevelPackages.org

        pkgs.graphviz
        pkgs.tinymist
      ];
    };
  in {
    packages.${system}.default = pkgs.symlinkJoin {
      name = "emacs";
      paths = [myEmacs];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/emacs \
        --prefix PATH : ${pkgs.lib.makeBinPath [
          (pkgs.aspellWithDicts (d: [d.en d.de]))
          pkgs.jdt-language-server
          (pkgs.callPackage ./lib/zotero-open-pdf.nix {})
          (pkgs.texliveBasic.withPackages (
            ps:
              with ps; [
                # needed for previews and such
                dvisvgm
                preview
                mylatexformat
                wrapfig
                amsmath
                ulem
                hyperref
                capt-of
                cm-super

                pgfplots
              ]
          ))
        ]}
      '';
    };
  };
}
