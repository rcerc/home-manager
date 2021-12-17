{ lib, pkgs, ... }:

{
  test.stubs.swayidle = { };
  programs.swayidle = {
    enable = true;
    idleHint = 300;
  };
  nmt.script = ''
    assertFileExists home-files/.config/swayidle/config
    assertFileContent home-files/.config/swayidle/config ${./idle-hint.conf}
  '';
}
