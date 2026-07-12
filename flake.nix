{
  description = "sshls — interactive SSH host selector built on fzf";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        sshls = pkgs.stdenv.mkDerivation {
          pname = "sshls";
          version = "0.1.0";

          src = ./.;

          nativeBuildInputs = [ pkgs.makeWrapper ];

          # Runtime tools the script shells out to.
          runtimeDeps = with pkgs; [
            bash
            fzf
            gawk
            openssh
            coreutils
            util-linux
            gnused
          ];

          dontConfigure = true;
          dontBuild = true;

          installPhase = ''
            runHook preInstall

            install -Dm755 sshls "$out/bin/sshls"
            install -Dm644 _sshls "$out/share/zsh/site-functions/_sshls"

            wrapProgram "$out/bin/sshls" \
              --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [
                bash fzf gawk openssh coreutils util-linux gnused
              ])}

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Interactive SSH host selector that parses ~/.ssh/config and picks with fzf";
            homepage = "https://github.com/dizider/sshls";
            license = licenses.mit;
            mainProgram = "sshls";
            platforms = platforms.unix;
          };
        };

        default = sshls;
      });

      apps = forAllSystems (pkgs: rec {
        sshls = {
          type = "app";
          program = "${self.packages.${pkgs.system}.sshls}/bin/sshls";
        };
        default = sshls;
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [ bash fzf gawk openssh util-linux ];
        };
      });
    };
}
