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

          javaPackage = pkgs.temurin-bin-25;

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
    };
}
