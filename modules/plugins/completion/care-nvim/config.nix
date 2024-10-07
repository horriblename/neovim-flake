{
  lib,
  config,
  ...
}: let
  inherit (lib.attrsets) mapAttrs';
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.binds) addDescriptionsToMappings;

  cfg = config.vim.autocomplete.care-nvim;
  cmpCfg = config.vim.autocomplete.nvim-cmp;

  self = import ./care-nvim.nix {inherit lib;};
  mappingDefinitions = self.options.vim.autocomplete.care-nvim.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;

  # TODO: extract into lib/binds.nix
  mkKeymap = mode: {
    description,
    value,
  }: action: opts:
    opts
    // {
      key = value;
      desc = description;
      inherit action mode;
    };
in {
  config.vim = mkIf cfg.enable {
    startPlugins = ["care-nvim" "care-cmp"];
    luaPackages = ["fzy"];

    autocomplete.care-nvim.setupOpts.sources =
      mkMerge
      [
        {nvim_lsp.enabled = true;}
        (mapAttrs' (name: _: {
            name = "cmp_${name}";
            value = {};
          })
          cmpCfg.sources)
        (mkIf cmpCfg.enable {cmp_nvim_lsp.enabled = lib.traceVal false;})
      ];

    keymaps = [
      (mkKeymap ["i"] mappings.confirm "<Plug>(CareConfirm)" {})
      (mkKeymap ["i"] mappings.next "<Plug>(CareSelectNext)" {})
      (mkKeymap ["i"] mappings.previous "<Plug>(CareSelectPrev)" {})
      (mkKeymap ["i"] mappings.close "<Plug>(CareClose)" {})
    ];

    pluginRC.care-nvim = ''
      require('care').setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
