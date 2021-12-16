{ config, lib, pkgs, ... }:

let cfg = config.programs.swayidle;
in {
  meta.maintainers = [ lib.maintainers.rcerc ];
  options.programs.swayidle = {
    enable = lib.mkEnableOption "swayidle";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.swayidle;
      defaultText = lib.literalExpression "pkgs.swayidle";
      description = ''
        The swayidle package to use.
      '';
    };
    timeout = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          timeout = lib.mkOption {
            type = lib.types.int;
            example = 300;
            description = ''
              Seconds of inactivity before executing <varname>timeoutCommand
              </varname>.
            '';
          };
          timeoutCommand = lib.mkOption {
            type = lib.types.str;
            example = lib.literalExpression
              "\${lib.getBin pkgs.swaylock}/bin/swaylock --daemonize";
            description = ''
              Command to execute after <varname>timeout</varname> seconds of
              inactivity.
            '';
          };
          resumeCommand = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = lib.literalExpression ''
              ''${lib.getBin pkgs.sway}/bin/swaynag --message "Welcome back!"'';
            description = ''
              Command to execute when there is activity again.
            '';
          };
        };
      });
      default = [ ];
      example = [
        {
          timeout = 300;
          timeoutCommand = lib.literalExpression
            "\${lib.getBin pkgs.swaylock}/bin/swaylock --daemonize";
        }
        {
          timeout = 600;
          timeoutCommand = lib.literalExpression
            ''''${lib.getBin pkgs.sway}/bin/swaymsg "output * dpms off"'';
          resumeCommand = lib.literalExpression
            ''''${lib.getBin pkgs.sway}/bin/swaymsg "output * dpms on"'';
        }
      ];
      description = ''
        Commands to execute before or after periods of inactivity.
      '';
    };
    beforeSleep = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        lib.literalExpression
        "\${lib.getBin pkgs.swaylock}/bin/swaylock --daemonize"
      ];
      description = ''
        If built with systemd support, commands to execute before systemd puts
        the computer to sleep.
      '';
    };
    afterResume = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        lib.literalExpression
        ''''${lib.getBin pkgs.sway}/bin/swaynag --message "Welcome back!"''
      ];
      description = ''
        If built with systemd support, commands to execute after logind signals
        that the computer resumed from sleep.
      '';
    };
    lock = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        lib.literalExpression
        "\${lib.getBin pkgs.swaylock}/bin/swaylock --daemonize"
      ];
      description = ''
        If built with systemd support, commands to execute when logind signals
        that the session should be locked.
      '';
    };
    unlock = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        lib.literalExpression
        ''''${lib.getBin pkgs.sway}/bin/swaynag --message "Welcome back!"''
      ];
      description = ''
        If built with systemd support, commands to execute after logind signals
        that the computer resumed from sleep.
      '';
    };
    idleHint = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      example = 300;
      description = ''
        If built with systemd support, seconds after IdleHint should be set to
        indicate an idle logind/elogind session.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."swayidle/config" = {
      text = (builtins.concatStringsSep "\n" ((map (timeout:
        "timeout ${toString timeout.timeout} ${
          lib.escapeShellArg timeout.timeoutCommand
        }${
          lib.optionalString (timeout.resumeCommand != null)
          " resume ${lib.escapeShellArg timeout.resumeCommand}"
        }") cfg.timeout)
        ++ (map (beforeSleep: "before-sleep ${lib.escapeShellArg beforeSleep}")
          cfg.beforeSleep)
        ++ (map (afterResume: "after-resume ${lib.escapeShellArg afterResume}")
          cfg.afterResume)
        ++ (map (lock: "lock ${lib.escapeShellArg lock}") cfg.lock)
        ++ (map (unlock: "unlock ${lib.escapeShellArg unlock}") cfg.unlock)
        ++ lib.optional (cfg.idleHint != null)
        "idlehint ${toString cfg.idleHint}" ++ [ "" ]));
    };
  };
}
