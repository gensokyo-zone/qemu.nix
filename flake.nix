{
    description = "arcnmx's nixlib";

    inputs = {
    };

    outputs = { ... }: {
        nixosModules.qemu = { ... }: {
            imports = [ ./modules/nixos ];
        };
    };
}