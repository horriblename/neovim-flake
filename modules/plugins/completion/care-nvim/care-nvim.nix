{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption either bool str nullOr int literalMD;
  inherit (lib.types) attrsOf submodule;
  inherit (lib.nvim.types) mkPluginSetupOption;

  sourceConfig = submodule {
    options = {
      enabled = mkOption {
        description = ''
          whether this source is enabled, or a lua function as a string that
          decides if this source is enabled.
        '';
        type = either bool str;
        default = true;
      };

      max_entries = mkOption {
        description = ''
          The maximum amount of entries which can be displayed by this source.
        '';
        type = nullOr int;
        default = null;
      };

      priority = mkOption {
        description = ''
          The priority of this source. Is more important than matching score
        '';
        type = nullOr int;
        default = null;
      };

      filter = mkOption {
        description = literalMD ''
          A lua function that filters entries by the source.

          The function signature should `fun(entry: care.entry): boolean`.
        '';
        type = nullOr str;
        default = null;
      };
    };
  };
in {
  options.vim = {
    autocomplete = {
      care-nvim = {
        enable = mkEnableOption "care.nvim";

        setupOpts = mkPluginSetupOption "care.nvim" {
          sources = mkOption {
            type = attrsOf sourceConfig;
          };
        };
      };
    };
  };
}
