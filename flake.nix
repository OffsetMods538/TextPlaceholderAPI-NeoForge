{
  description = "A Nix flake for Java Minecraft mod development";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, ... }@inputs: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forEachSupportedSystem = f:
      inputs.nixpkgs.lib.genAttrs supportedSystems (system:
        f rec {
          pkgs = import inputs.nixpkgs {
            inherit system;
          };

          javaPackage = pkgs.temurin-bin-21;

          libs = with pkgs; [
            stdenv.cc.cc.lib

            ## native versions
            glfw3-minecraft
            openal

            ## openal
            alsa-lib
            libjack2
            libpulseaudio
            pipewire

            ## glfw
            libGL
            libx11
            libxcursor
            libxext
            libxrandr
            libxxf86vm

            vulkan-loader # VulkanMod's lwjgl
            shaderc

            udev # oshi
            flite
          ];
        }
      );
    in {
      devShells = forEachSupportedSystem ({ pkgs, libs, javaPackage }: {
        default = pkgs.mkShellNoCC {
          packages = [
            javaPackage
          ];

          buildInputs = libs;

          JAVA_HOME = javaPackage;
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath libs;
        };
      });

      apps = forEachSupportedSystem ({ pkgs, ... }: let
        publish = pkgs.writeShellApplication {
          name = "publish";

          runtimeInputs = with pkgs; [
            gnupg
            coreutils
          ];

          text = ''
            set +x

            creds_gpg="/persist/$USER/maven_credentials.gpg"

            read -r MAVEN_USERNAME MAVEN_PASSWORD < <(gpg --quiet --batch --decrypt "$creds_gpg")

            export MAVEN_USERNAME MAVEN_PASSWORD

            if [ -z "$MAVEN_USERNAME" ] || [ -z "$MAVEN_PASSWORD" ]; then
              echo "Missing maven credentials" >&2
              exit 1
            fi

            exec ./gradlew publishMavenPublicationToOffsetMonkey538Repository
          '';
        };
      in {
        publish = {
          type = "app";
          program = "${publish}/bin/publish";
        };
      });
    };
}
