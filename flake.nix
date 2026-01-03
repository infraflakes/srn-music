{
  description = "A supercharged cd wrapper with aliases and TUI.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        buildSmusic = {
          src,
          version,
        }:
          pkgs.buildGoModule {
            pname = "smusic";
            inherit version src;
            preBuild = ''
              export CGO_ENABLED=0
            '';
            vendorHash = "sha256-97Uu5s7ay21ALUMVAdtMVnvTIdnW8CUnQ5w2aL1cAfs="; # Update if source changes
            ldflags = [
              "-s"
              "-w"
              "-X main.version=${version}"
            ];
            nativeBuildInputs = [pkgs.installShellFiles];
            postInstall = ''
              mv $out/bin/srn-music $out/bin/smusic
            '';
            postFixup = ''
              installShellCompletion --fish ${src}/completions/smusic.fish
              installShellCompletion --zsh ${src}/completions/smusic.zsh
              installShellCompletion --bash ${src}/completions/smusic.bash
            '';
          };

        cleanedSource = pkgs.lib.cleanSourceWith {
          src = ./.;
          filter = path: type: let
            baseName = baseNameOf path;
          in
            baseName == ".version" || pkgs.lib.cleanSourceFilter path type;
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            golangci-lint
            cmake
            goreleaser
          ];
        };

        packages.default = buildSmusic {
          src = cleanedSource;
          version = let
            versionFile = "${cleanedSource}/.version";
          in
            pkgs.lib.escapeShellArg (
              if builtins.pathExists versionFile
              then builtins.readFile versionFile
              else self.shortRev or "dev"
            );
        };

        apps.default = flake-utils.lib.mkApp {drv = self.packages.${system}.default;};
      }
    );
}
