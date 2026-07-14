{
  description = "dotfiles";

  inputs = {
    # Use `github:NixOS/nixpkgs/nixpkgs-26.05-darwin` to use Nixpkgs 26.05.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    # Use `github:nix-darwin/nix-darwin/nix-darwin-26.05` to use Nixpkgs 26.05.
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # One-source theming: set flavor + accent once, themes everything (bat, starship, btop, fzf...).
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = inputs@{ self, nix-darwin, nix-homebrew, home-manager, nixpkgs, catppuccin }:
    let
      # The one username line to change if this isn't your machine.
      user = "ryan";
    in
    {
      darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit user; };
        modules = [
          ./configuration.nix
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # If an app already wrote a real file where we want an edit-in-place
            # symlink (Zed/Claude/VSCode do this on first launch), move it aside
            # to <file>.hm-backup instead of aborting activation.
            home-manager.backupFileExtension = "hm-backup";
            home-manager.extraSpecialArgs = { inherit user; };
            home-manager.users.${user} = {
              imports = [
                ./home.nix
                catppuccin.homeModules.catppuccin
              ];
            };
          }
        ];
      };
    };
}
