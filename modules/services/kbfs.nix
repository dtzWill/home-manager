{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.kbfs;

in

{
  options = {
    services.kbfs = {
      enable = mkEnableOption "Keybase File System";

      mountPoint = mkOption {
        type = types.str;
        default = "keybase";
        description = ''
          Mount point for the Keybase filesystem, relative to
          <envar>HOME</envar>.
        '';
      };

      extraFlags = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [
          "-label kbfs"
          "-mount-type normal"
        ];
        description = ''
          Additional flags to pass to the Keybase filesystem on launch.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.kbfs = {
      Unit = {
        Description = "Keybase File System";
        Requires = [ "keybase.service" ];
        After = [ "keybase.service" ];
      };

      Service =
        let
          mountPoint = "\"%h/${cfg.mountPoint}\"";
        in {
          Environment = "PATH=/run/wrappers/bin:${pkgs.keybase}/bin:$PATH KEYBASE_SYSTEMD=1";
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountPoint}"
           + " && /run/wrappers/bin/fusermount -ul ${mountPoint}";
          ExecStart ="${pkgs.keybase}/bin/kbfsfuse ${toString cfg.extraFlags} ${mountPoint}";
          ExecStopPost = "/run/wrappers/bin/fusermount -ul ${mountPoint}";
          Restart = "on-failure";
          #PrivateTmp = true;
        };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    home.packages = [ pkgs.keybase ];
    services.keybase.enable = true;
  };
}
