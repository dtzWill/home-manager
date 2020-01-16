{ pkgs ? import <nixpkgs> {} }:

let

  nmt = pkgs.fetchFromGitLab {
    owner = "rycee";
    repo = "nmt";
    rev = "89fb12a2aaa8ec671e22a033162c7738be714305";
    sha256 = "07yc1jkgw8vhskzk937k9hfba401q8rn4sgj9baw3fkjl9zrbcyf";
  };

in

import nmt {
  inherit pkgs;
  modules = import ../modules/modules.nix { inherit pkgs; lib = pkgs.lib; };
  testedAttrPath = [ "home" "activationPackage" ];
  tests = {
    browserpass = ./modules/programs/browserpass.nix;
    mbsync = ./modules/programs/mbsync.nix;
    texlive-minimal = ./modules/programs/texlive-minimal.nix;
    xresources = ./modules/xresources.nix;
  }
  // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux (
    {
      getmail = ./modules/programs/getmail.nix;
      i3-keybindings = ./modules/services/window-managers/i3-keybindings.nix;
    }
    // import ./modules/misc/pam
    // import ./modules/misc/xdg
    // import ./modules/misc/xsession
    // import ./modules/programs/firefox
    // import ./modules/programs/rofi
    // import ./modules/services/sxhkd
    // import ./modules/systemd
  )
  // import ./lib/types
  // import ./modules/files
  // import ./modules/home-environment
  // import ./modules/misc/fontconfig
  // import ./modules/programs/alacritty
  // import ./modules/programs/bash
  // import ./modules/programs/git
  // import ./modules/programs/gpg
  // import ./modules/programs/newsboat
  // import ./modules/programs/readline
  // import ./modules/programs/ssh
  // import ./modules/programs/tmux
  // import ./modules/programs/zsh;
}
