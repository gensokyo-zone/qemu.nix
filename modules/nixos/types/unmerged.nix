{ types, lib, ... }: with lib; {
  config.lib.types = with types; {
    unmerged = {
      values = mkOptionType {
        name = "unmergedValues";
        merge = loc: defs: map (def: def.value) defs;
      };
      attrs = attrsOf unmerged.values;
      type = unmerged.values;
      freeformType = unmerged.attrs;

      merge = mkMerge;
      mergeAttrs = mapAttrs (_: unmerged.merge);
    };
  };
}