{ lib, pkgs, ... }:

{
  test.stubs = {
    swayidle = { };
    swaylock = { };
  };
  programs.swayidle = {
    enable = true;
    lock = [ "${lib.getBin pkgs.swaylock}/bin/swaylock --daemonize" ];
  };
  nmt.script = ''
    assertFileExists home-files/.config/swayidle/config
    assertFileContent home-files/.config/swayidle/config ${
      pkgs.substituteAll {
        swaylock = "${lib.getBin pkgs.swaylock}/bin/swaylock";
        src = ./lock.conf;
      }
    }
  '';
}
