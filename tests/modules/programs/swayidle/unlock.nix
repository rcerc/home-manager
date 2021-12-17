{ lib, pkgs, ... }:

{
  test.stubs = {
    sway = { };
    swayidle = { };
  };
  programs.swayidle = {
    enable = true;
    unlock =
      [ ''${lib.getBin pkgs.sway}/bin/swaynag --message "Welcome back!"'' ];
  };
  nmt.script = ''
    assertFileExists home-files/.config/swayidle/config
    assertFileContent home-files/.config/swayidle/config ${
      pkgs.substituteAll {
        swaynag = "${lib.getBin pkgs.sway}/bin/swaynag";
        src = ./unlock.conf;
      }
    }
  '';
}
