{
  description = "Patched antigravity-hub";

  inputs.patch-src = {
    url = "github:QNIX-Dev/eligibility-antigravity-patcher";   # the repo that holds the patch script
    flake = false;
  };

  outputs = { self, patch-src }: {
    nixosModules.default = { ... }: {
      nixpkgs.overlays = [
        (final: prev: {
          antigravity-hub-patched = prev.antigravity-hub.overrideAttrs (old: {
            nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.python3 ];

            postInstall = (old.postInstall or "") + ''
              target="$out/share/antigravity/resources/bin/language_server"
              [ -e "$target" ] || { echo "language_server not found at $target"; exit 1; }
              chmod u+w "$target"
              python3 ${patch-src}/manager.py patch manager --path-manager "$target"
              [ -e "$target.agybak" ] || { echo "expected backup file $target.agybak not found"; exit 1; }
              rm -f "$target.agybak"
            '';
          });
        })
      ];
    };
  };
}
