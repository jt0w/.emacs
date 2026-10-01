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

        pkgs.graphviz
        pkgs.tinymist

		(epkgs.melpaBuild {
		  ename = "reader";
		  pname = "emacs-reader";
		  version = "2026101";
		  src = pkgs.fetchFromGitea {
			domain = "codeberg.org";
			owner = "divyaranjan";
			repo = "emacs-reader";
			rev = "3932ccbd56673f695c7fe4c843fb5567898c9aa7"; # replace with 'tag' for stable
			hash = "sha256-Ht2DVWWq1YspM6gdoT4h8vaLvu1FyvJHHcEaikmyj04=";
		  };
		  files = ''(:defaults "render-core.so")'';
		  nativeBuildInputs = with pkgs; [ pkg-config ];
		  buildInputs = with pkgs; [ gcc mupdf gnumake pkg-config ];
		  preBuild = "make clean all";
		  ignoreCompilationError = true;
		})

		pkgs.mupdf-headless
      ];

    };
  in {
    packages.${system}.default = myEmacs;

    apps.${system}.default = {
      type = "app";
      program = "${myEmacs}/bin/emacs";
    };
  };
}
