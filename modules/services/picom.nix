{ config, lib, pkgs, ... }:

with lib;
with builtins;

let

  cfg = config.services.picom;

  configFile = pkgs.writeText "picom.conf" (optionalString cfg.fade ''
    # fading
    fading = true;
    fade-delta    = ${toString cfg.fadeDelta};
    fade-in-step  = ${elemAt cfg.fadeSteps 0};
    fade-out-step = ${elemAt cfg.fadeSteps 1};
    fade-exclude  = ${toJSON cfg.fadeExclude};
  '' + optionalString cfg.shadow ''

    # shadows
    shadow = true;
    shadow-offset-x = ${toString (elemAt cfg.shadowOffsets 0)};
    shadow-offset-y = ${toString (elemAt cfg.shadowOffsets 1)};
    shadow-opacity  = ${cfg.shadowOpacity};
    shadow-exclude  = ${toJSON cfg.shadowExclude};
  '' + optionalString cfg.blur ''

    # blur
    blur-background         = true;
    blur-background-exclude = ${toJSON cfg.blurExclude};
  '' + ''

    # opacity
    active-opacity   = ${cfg.activeOpacity};
    inactive-opacity = ${cfg.inactiveOpacity};
    inactive-dim     = ${cfg.inactiveDim};
    opacity-rule     = ${toJSON cfg.opacityRule};

    # other options
    backend = ${toJSON cfg.backend};
    vsync = ${toJSON cfg.vSync};
    refresh-rate = ${toString cfg.refreshRate};
  '' + cfg.extraOptions);

in {

  options.services.picom= {
    enable = mkEnableOption "Picom X11 compositor";

    blur = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable background blur on transparent windows.
      '';
    };

    blurExclude = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "class_g = 'slop'" "class_i = 'polybar'" ];
      description = ''
        List of windows to exclude background blur.
        See the
        <citerefentry>
          <refentrytitle>picom</refentrytitle>
          <manvolnum>1</manvolnum>
        </citerefentry>
        man page for more examples.
      '';
    };

    fade = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Fade windows in and out.
      '';
    };

    fadeDelta = mkOption {
      type = types.int;
      default = 10;
      example = 5;
      description = ''
        Time between fade animation step (in ms).
      '';
    };

    fadeSteps = mkOption {
      type = types.listOf types.str;
      default = [ "0.028" "0.03" ];
      example = [ "0.04" "0.04" ];
      description = ''
        Opacity change between fade steps (in and out).
      '';
    };

    fadeExclude = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "window_type *= 'menu'" "name ~= 'Firefox$'" "focused = 1" ];
      description = ''
        List of conditions of windows that should not be faded.
        See the
        <citerefentry>
          <refentrytitle>picom</refentrytitle>
          <manvolnum>1</manvolnum>
        </citerefentry>
        man page for more examples.
      '';
    };

    shadow = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Draw window shadows.
      '';
    };

    shadowOffsets = mkOption {
      type = types.listOf types.int;
      default = [ (-15) (-15) ];
      example = [ (-10) (-15) ];
      description = ''
        Horizontal and vertical offsets for shadows (in pixels).
      '';
    };

    shadowOpacity = mkOption {
      type = types.str;
      default = "0.75";
      example = "0.8";
      description = ''
        Window shadows opacity (number in range 0 - 1).
      '';
    };

    shadowExclude = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "window_type *= 'menu'" "name ~= 'Firefox$'" "focused = 1" ];
      description = ''
        List of conditions of windows that should have no shadow.
        See the
        <citerefentry>
          <refentrytitle>picom</refentrytitle>
          <manvolnum>1</manvolnum>
        </citerefentry>
        man page for more examples.
      '';
    };

    activeOpacity = mkOption {
      type = types.str;
      default = "1.0";
      example = "0.8";
      description = ''
        Opacity of active windows.
      '';
    };

    inactiveDim = mkOption {
      type = types.str;
      default = "0.0";
      example = "0.2";
      description = ''
        Dim inactive windows.
      '';
    };

    inactiveOpacity = mkOption {
      type = types.str;
      default = "1.0";
      example = "0.8";
      description = ''
        Opacity of inactive windows.
      '';
    };

    opacityRule = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "87:class_i ?= 'scratchpad'" "91:class_i ?= 'xterm'" ];
      description = ''
        List of opacity rules.
        See the
        <citerefentry>
          <refentrytitle>picom</refentrytitle>
          <manvolnum>1</manvolnum>
        </citerefentry>
        man page for more examples.
      '';
    };

    backend = mkOption {
      type = types.str;
      default = "glx";
      description = ''
        Backend to use: <literal>glx</literal> or <literal>xrender</literal>.
      '';
    };
    experimentalBackends = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Use experimental backends.
      '';
    };
    dbus = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable remote control via D-BUS.
      '';
    };
    maxBrightness = mkOption {
      type = types.float;
      default = 1.0;
      description = ''
        Dim bright windows so their brightness doesn’t exceed this set value, 1.0 disables.
      '';
    };

    vSync = mkOption {
      type = types.either types.str types.bool; # new version makes this bool
      default = "none";
      example = "opengl-swc";
      description = ''
        Enable vertical synchronization using the specified method.
        See the
        <citerefentry>
          <refentrytitle>picom</refentrytitle>
          <manvolnum>1</manvolnum>
        </citerefentry>
        man page for available methods.
      '';
    };

    refreshRate = mkOption {
      type = types.int;
      default = 0;
      example = 60;
      description = ''
        Screen refresh rate (0 = automatically detect).
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.picom;
      defaultText = literalExample "pkgs.picom";
      example = literalExample "pkgs.picom";
      description = ''
        Picom derivation to use.
      '';
    };

    extraOptions = mkOption {
      type = types.str;
      default = "";
      example = ''
        unredir-if-possible = true;
        dbe = true;
      '';
      description = ''
        Additional picom configuration.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services.picom = {
      Unit = {
        Description = "Picom X11 compositor";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };

      Service = {
        ExecStart = lib.concatStringsSep " " ([
          "${cfg.package}/bin/picom"
          "--config" configFile
          "--max-brightness" (builtins.toString cfg.maxBrightness)
        ]
        ++ lib.optional cfg.experimentalBackends "--experimental-backends"
        ++ lib.optional cfg.dbus "--dbus"
        );
        Restart = "always";
        RestartSec = 3;
      };
    };
  };
}
