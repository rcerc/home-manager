{ lib, pkgs, ... }:

{
  test.stubs = {
    sway = { };
    swayidle = { };
    swaylock = { };
  };
  programs.swayidle = {
    enable = true;
    timeout = [
      {
        timeout = 300;
        timeoutCommand = "${lib.getBin pkgs.swaylock}/bin/swaylock --daemonize";
      }
      {
        timeout = 600;
        timeoutCommand =
          ''${lib.getBin pkgs.sway}/bin/swaymsg "output * dpms off"'';
        resumeCommand =
          ''${lib.getBin pkgs.sway}/bin/swaymsg "output * dpms on"'';
      }
    ];
  };
  nmt.script = ''
    assertFileExists home-files/.config/swayidle/config
    assertFileContent home-files/.config/swayidle/config ${
      pkgs.substituteAll {
        swaylock = "${lib.getBin pkgs.swaylock}/bin/swaylock";
        swaymsg = "${lib.getBin pkgs.sway}/bin/swaymsg";
        src = ./timeout.conf;
      }
    }
  '';
}
