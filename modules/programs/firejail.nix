{ config, lib, pkgs, ... }:

let cfg = config.programs.firejail;
in {
  meta.maintainers = [ lib.maintainers.rcerc ];
  options.programs.firejail = {
    enable = lib.mkOption {
      description = ''
        Whether to enable Firejail.
      '';
      default = cfg.wrappedCommands != { };
      type = lib.types.bool;
      example = false;
    };
    wrappedCommands = lib.mkOption {
      description = ''
        Commands to wrap with Firejail and install as attribute names.
      '';
      default = { };
      type = lib.types.attrsOf (lib.types.either lib.types.path
        (lib.types.submodule ({ name, ... }: {
          options = {
            command = lib.mkOption {
              description = ''
                Executable and arguments to wrap.
              '';
              type = lib.types.listOf lib.types.str;
              example = lib.literalExpression
                ''[ "''${pkgs.google-chrome}/bin/google-chrome-stable" ]'';
            };
            firejailArgs = lib.mkOption {
              description = ''
                Arguments to pass to <command>firejail</command>.
              '';
              default = [ ];
              type = lib.types.listOf lib.types.str;
              example = [ "--debug" "--hostname=firejail" ];
            };
            profile = lib.mkOption {
              description = ''
                Path of Firejail profile to load.
              '';
              default = "${pkgs.firejail}/etc/firejail/${name}.profile";
              defaultText = lib.literalExpression
                ''"''${pkgs.firejail}/etc/firejail/''${command}.profile"'';
              type = lib.types.nullOr lib.types.path;
              example = lib.literalExpression "./foo.profile";
            };
          };
        })));
      example = lib.literalExpression ''
        {
          firefox = {
            command = [ "''${lib.getBin pkgs.firefox-wayland}/bin/firefox" ];
            profile = "''${pkgs.firejail}/etc/firejail/firefox-wayland.profile";
          };
          mpv = {
            command = [ "''${lib.getBin pkgs.mpv}/bin/mpv" ];
            firejailArgs = [ "--allusers" ];
          };
        }
      '';
    };
  };
  config.home.packages = lib.mkIf cfg.enable (lib.mapAttrsToList (cmd: src:
    pkgs.writeShellScriptBin cmd ''
      /run/wrappers/bin/firejail --profile=${
        if lib.types.path.check src then
          "${pkgs.firejail}/etc/firejail/${
            lib.escapeShellArg (baseNameOf src)
          }.profile -- ${lib.escapeShellArg src}"
        else
          "${lib.escapeShellArg src.profile} ${
            lib.escapeShellArgs src.firejailArgs
          } -- ${lib.escapeShellArgs src.command}"
      } "$@"'') cfg.wrappedCommands);
}
