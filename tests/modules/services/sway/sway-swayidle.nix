{ lib, pkgs, ... }:

{
  imports = [ ./sway-stubs.nix ];

  test.stubs.swayidle = { };

  wayland.windowManager.sway = {
    package = pkgs.sway;
    enable = true;
    swayidle = {
      enable = true;
      args = [ "-d" "-w" ];
    };
  };

  nmt.script = ''
    assertFileExists home-files/.config/sway/config
    assertFileContains home-files/.config/sway/config \
      "exec ${lib.getBin pkgs.swayidle}/bin/swayidle '-d' '-w'"
  '';
}
