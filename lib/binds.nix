{lib}: let
  inherit (lib.options) mkOption;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.types) nullOr str;
  inherit (lib.attrsets) isAttrs mapAttrs;
  inherit (lib.generators) mkLuaInline;

  mkLuaBinding = mode: key: action: desc:
    mkIf (key != null) {
      ${key} = {
        inherit mode action desc;
        lua = true;
        silent = true;
      };
    };

  mkExprBinding = mode: key: action: desc:
    mkIf (key != null) {
      ${key} = {
        inherit mode action desc;
        lua = true;
        silent = true;
        expr = true;
      };
    };

  mkBinding = mode: key: action: desc:
    mkIf (key != null) {
      ${key} = {
        inherit mode action desc;
        silent = true;
      };
    };

  mkMappingOption = description: default:
    mkOption {
      type = nullOr str;
      inherit default description;
    };

  # Utility function that takes two attrsets:
  # { someKey = "some_value" } and
  # { someKey = { description = "Some Description"; }; }
  # and merges them into
  # { someKey = { value = "some_value"; description = "Some Description"; }; }
  addDescriptionsToMappings = actualMappings: mappingDefinitions:
    mapAttrs (name: value: let
      isNested = isAttrs value;
      returnedValue =
        if isNested
        then addDescriptionsToMappings actualMappings.${name} mappingDefinitions.${name}
        else {
          inherit value;
          inherit (mappingDefinitions.${name}) description;
        };
    in
      returnedValue)
    actualMappings;

  mkSetBinding = mode: binding: action:
    mkBinding mode binding.value action binding.description;

  mkSetExprBinding = mode: binding: action:
    mkExprBinding mode binding.value action binding.description;

  mkSetLuaBinding = mode: binding: action:
    mkLuaBinding mode binding.value action binding.description;

    # Utility function that takes two attrsets:
    # { someKey = "some_value" } and
    # { someKey = { description = "Some Description"; }; }
    # and merges them into
    # { someKey = { value = "some_value"; description = "Some Description"; }; }
    addDescriptionsToMappings = actualMappings: mappingDefinitions:
      mapAttrs (name: value: let
        isNested = isAttrs value;
        returnedValue =
          if isNested
          then addDescriptionsToMappings actualMappings."${name}" mappingDefinitions."${name}"
          else {
            inherit value;
            inherit (mappingDefinitions."${name}") description;
          };
      in
        returnedValue)
      actualMappings;

    mkSetBinding = binding: action:
      mkBinding binding.value action binding.description;

    mkSetExprBinding = binding: action:
      mkExprBinding binding.value action binding.description;

    mkSetLuaBinding = binding: action:
      mkLuaBinding binding.value action binding.description;

    pushDownDefault = attr: mapAttrs (_: mkDefault) attr;

    mkLznBinding = mode: lhs: rhs: desc: {
      inherit mode lhs rhs desc;
    };

    mkSetLznBinding = binding: action: {
      lhs = binding.value;
      rhs = action;
      desc = binding.description;
    };

    mkSetLuaLznBinding = binding: action: {
      lhs = binding.value;
      rhs = mkLuaInline "function() ${action} end";
      desc = binding.description;
    };
  };
in
  binds
