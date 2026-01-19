{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.security.fscrypt;
in
{
  options = {
    security.fscrypt = {
      enable = lib.mkEnableOption ''
        Native Filesystem Encryption and the {command}`fscrypt` userspace management tool therefor
      '';

      onlyRootCreatesPoliciesAndProtectors = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether creation of fscrypt metadata (policies and protectors) is restricted to
          only the root user.

          This restriction prevents malicious users from filling up the filesystem.
        '';
      };

      enabledFileSystems = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        description = ''
          Additional filesystems for which fscrypt should be enabled.  List the mount point
          for each filesystem.

          Directories listed here will have the necessary .fscrypt/ directory pre-popluated,
          eliminating the need to run {command}`fscrypt setup`.  `/` is always enabled.
        '';
        default = [ ];
      };

      hashCosts = lib.mkOption {
        description = ''
          Parameters describing how difficult passphrase hashing should be for this machine.

          Run {command}`fscrypt setup`, with the `--time` option if desired, and transcribe
          the values it generates from {file}`/etc/fscrypt.conf`.
        '';
        type = lib.types.submodule {
          options = {
            time = lib.mkOption {
              type = lib.types.int;
              description = "the generated `time` value";
            };
            memory = lib.mkOption {
              type = lib.types.int;
              description = "the generated `memory` value";
            };
            parallelism = lib.mkOption {
              type = lib.types.int;
              description = "the generated `parallelism` value";
            };
            truncation_fixed = lib.mkOption {
              type = lib.types.bool;
              description = "the generated `truncation_fixed` value";
            };
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    security.pam.enableFscrypt = true;

    environment.etc."fscrypt.conf".source = pkgs.writeText "fscrypt.conf" (
      builtins.toJSON {
        source = "custom_passphrase";
        hash_costs = {
          # these values are not stored as JSON numbers for some unknown reason
          time = toString cfg.hashCosts.time;
          memory = toString cfg.hashCosts.memory;
          parallelism = toString cfg.hashCosts.parallelism;
          truncation_fixed = cfg.hashCosts.truncation_fixed;
        };
        options = {
          padding = "32";
          contents = "AES_256_XTS";
          filenames = "AES_256_CTS";
          policy_version = "2";
        };
        use_fs_keyring_for_v1_policies = false;
        allow_cross_user_metadata = false;
      }
    );

    systemd.tmpfiles.settings =
      let
        onlyRootCreatesPnPdir = {
          d = {
            user = "root";
            group = "root";
            mode = "0755";
          };
        };
        otherUsersCreatePnPdir = {
          d = onlyRootCreatesPnPdir.d // {
            mode = "1777";
          };
        };
        pnpDir =
          if cfg.onlyRootCreatesPoliciesAndProtectors then onlyRootCreatesPnPdir else otherUsersCreatePnPdir;
        escapeDir = lib.replaceString "/" "-slash-";
        makeThreeFscryptDirs = path: [
          {
            name = "fscrypt-create" + escapeDir path + "-dir";
            value = {
              ${path + "/.fscrypt"} = onlyRootCreatesPnPdir;
            };
          }
          {
            name = "fscrypt-create" + escapeDir path + "-policies-dir";
            value = {
              ${path + "/.fscrypt/policies"} = pnpDir;
            };
          }
          {
            name = "fscrypt-create" + escapeDir path + "-protectors-dir";
            value = {
              ${path + "/.fscrypt/protectors"} = pnpDir;
            };
          }
        ];
      in
      builtins.listToAttrs (builtins.concatMap makeThreeFscryptDirs (cfg.enabledFileSystems ++ [ "" ]));
  };
}
