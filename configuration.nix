{ config, pkgs, ... }:
{
    imports =[
        ./hardware-configuration.nix
        (import "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/release-20.03.tar.gz}/nixos")
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "nixos";
    time.timeZone = "Europe/Minsk";


    nixpkgs.config.allowUnfree = true;
    programs.fish.enable = true;

    environment.systemPackages = with pkgs; [
        # system
        wget
        htop
        neofetch
        git
        lm_sensors
        bsod


        # server
        screen
        transmission

        # langs
        (python3.withPackages (py: with py; [ requests pytest ]))
        pipenv

    ];

    # services
    services.openssh = {
        enable = true;
        permitRootLogin = "yes";
    };

    services.transmission = {
        enable = true;
        settings = {
            "download-dir" = "/home/sambashare/[torrent]";
            "incomplete-dir-enabled" = false;
            "rpc-enabled" = true;
            "rpc-username" = "liza";
            "rpc-password" = "fowler";
            "rpc-whitelist-enabled" = false;
            "umask" = "000";
        };
    };
    systemd.services.transmission.serviceConfig.UMask = pkgs.lib.mkForce "000";

    services.samba = {
        enable = true;
        securityType = "user";
        extraConfig = ''
            workgroup = WORKGROUP
            server string = smbnix
            server role = standalone server
            guest account = nobody
            security = user
            map to guest = Bad User
        '';
        shares = {
            sambashare = {
                path = "/home/sambashare";
                browseable = "yes";
                writable = "yes";
                "guest ok" = "yes";
                public = "yes";
            };
        };
    };

    services.nginx = {
        enable = true;
        virtualHosts."main".root = "/var/www";
    };

    services.aria2 = {
        enable = true;
        downloadDir = "/home/sambashare/[download]";
        rpcSecret = "pony";
        # openPorts = true;
        rpcListenPort = 6800;
        extraArguments = "--rpc-listen-all";
    };
    systemd.services.aria2.serviceConfig.UMask = pkgs.lib.mkForce "000";

    networking.firewall.enable = false;


    fonts = {
        enableFontDir = true;
        enableDefaultFonts = true;
        fonts = with pkgs; [
            hack-font
            fira-code
            ubuntu_font_family
            inconsolata
            noto-fonts
            noto-fonts-emoji
            iosevka
            powerline-fonts
        ];
    };

    users.extraUsers.user = {
        isNormalUser = true;
        home = "/home/user";
        createHome = true;
        extraGroups = [ "wheel" "networkmanager" ];
        uid = 1000;
        shell = "/run/current-system/sw/bin/fish";
    };
    home-manager.users.user = { pkgs, ... }: {
        programs = {
            git = {
                enable = true;
                userName  = "ponycoder";
                userEmail = "theponycoder@gmail.com";
            };

            fish = {
                enable = true;
                shellAliases = {
                    "nrb" = "sudo nixos-rebuild switch";
                    "nrbc" = "sudo nixos-rebuild switch && updconf";
                    "npu" = "nix-prefetch-url --unpack";
                    "freboot" = "sudo systemctl kexec";
                    "lsconf" = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
                };
                functions = {
                    fish_greeting = "neofetch";
                    updconf = ''
                        git --git-dir="/etc/nixos/.git" --work-tree=/etc/nixos add -A
                        git --git-dir="/etc/nixos/.git" --work-tree=/etc/nixos commit -m "$argv"
                        git --git-dir="/etc/nixos/.git" --work-tree=/etc/nixos push origin master
                    '';
                };
                plugins = [

                	# {
                	#     name = "theme-l";
                	#     src = pkgs.fetchFromGitHub {
                	#     	owner = "oh-my-fish";
                	#     	repo = "theme-l";
                	#     	rev = "master";
                	#     	sha256 = "1sjsnd4wn1zxail88liwplhfamqg2n0ihlivb2fv840r676f9ky3";
                	#     };
                	# }

                    {
                        name = "fish-plugins";
                        src = fetchGit {
                            url = "https://github.com/ThePonyCoder/fish-plugins.git";
                            ref = "master";
                        };
                    }
                ];
            };
        };
    };

    system.stateVersion = "20.03";
}
