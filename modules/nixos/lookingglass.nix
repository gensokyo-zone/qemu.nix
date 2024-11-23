let
  lookingGlassModule = { name, config, machineConfig, lib, ... }: with lib; {
    options = with types; {
      enable = mkEnableOption "LookingGlass" // {
        default = true;
      };
      name = mkOption {
        type = str;
        default = "looking-glass-${name}";
      };
      sizeMB = mkOption {
        type = int;
        default = 64;
      };
      kvmfrIndex = mkOption {
        type = nullOr int;
        default = null;
        example = 0;
      };
      path = mkOption {
        type = path;
        default = if config.kvmfrIndex != null then "/dev/kvmfr${toString config.kvmfrIndex}" else machineConfig.state.runtimePath + "/${config.name}";
      };
    };
  };
in { pkgs, config, lib, ... }: with lib; let
  cfg = config.lookingGlass;
in {
  options.lookingGlass = with lib.types; {
    devices = mkOption {
      type = attrsOf (submoduleWith {
        modules = [ lookingGlassModule ];
        specialArgs = {
          machineConfig = config;
        };
      });
      default = {};
    };
    enabled = mkOption {
      type = bool;
    };
    kvmfr.enabled = mkOption {
      type = bool;
    };
  };
  config = {
    lookingGlass = let
      enabledDevices = filter (lg: lg.enable) (attrValues cfg.devices);
      kvmfrDevices = filter (lg: lg.kvmfrIndex != null) enabledDevices;
    in {
      enabled = mkOptionDefault (enabledDevices != []);
      kvmfr.enabled = mkOptionDefault (kvmfrDevices != []);
    };
    ivshmem.devices = mapAttrs' (_: lg: nameValuePair lg.name (mkIf lg.enable (mapAttrs (_: mkOptionDefault) {
      inherit (lg) sizeMB path;
    }))) cfg.devices;
    systemd.unit = mkIf cfg.kvmfr.enabled {
      serviceConfig.ExecStartPre = [
        "+${pkgs.kmod}/bin/modprobe kvmfr"
      ];
    };
  };
}
