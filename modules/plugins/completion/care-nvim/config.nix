{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib.attrsets) mapAttrs';
  inherit (lib.modules) mkIf;
  cfg = config.vim.autocomplete;
in {
  vim = mkIf cfg.care-nvim.enable {
    startPlugins = ["care-nvim" "care-cmp"];
    luaPackages = [pkgs.fzy];

    autocomplete.care-nvim.setupOpts.sources =
      mapAttrs' (name: _: {
        name = "cmp_" ++ name;
        value = {};
      })
      cfg.sources;
  };
}
