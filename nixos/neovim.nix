{ config, pkgs,  ... }:

{
	nixpkgs.overlays = [
		(import (builtins.fetchTarball {
			 url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
			 }))
	];

	programs.neovim = {
		enable = true;
		package = pkgs.neovim-nightly;
		viAlias = true;
		vimAlias = true;
		configure = {
		    customRC = (builtins.readFile ./init.vim);
		    plug.plugins = with pkgs.vimPlugins; [
                 vim-go
            ];
            packages.myPlugins = with pkgs.vimPlugins; {
            start = [
                vim-plug
                (nvim-treesitter.withPlugins (
                    plugins: with plugins; [
                        tree-sitter-nix
                        tree-sitter-python
                    ]
                ))
            ];
            };
		};
	};
}
