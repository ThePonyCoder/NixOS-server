
{ config, pkgs, ... }:

{
    imports =[
        ./hardware-configuration.nix
        # (import "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/release-19.09.tar.gz}/nixos")
        (import "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/release-20.03.tar.gz}/nixos")

        # <home-manager/nixos>
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "nixos";

    time.timeZone = "Europe/Minsk";

    programs = {
        fish.enable = true;
    };

    nixpkgs.config.allowUnfree = true;
    # nixpkgs.config.allowBroken = true;
    environment.systemPackages = with pkgs; [
        # system
        wget
        htop
        neofetch
        git
        python3
        lm_sensors
        bsod
        # haskellPackages.update-nix-fetchgit


        # server
        screen
        transmission

        # langs
        (python3.withPackages (py: [ py.requests py.pytest]))
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
                    "npu" = "nix-prefetch-url --unpack";
                    "freboot" = "sudo systemctl kexec";
                    "lsconf" = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
                    # "updconf" = "git add . & git commit -m . & git push origin master";

                };
                functions = {
                    fish_greeting = "neofetch";
                    updconf = ''
                        git --git-dir=/etc/nixos/.git --work-tree=/etc/nixos /etc/nixos add .
                        git --git-dir=/etc/nixos/.git --work-tree=/etc/nixos commit -m "$argv"
                        git --git-dir=/etc/nixos/.git --work-tree=/etc/nixos push origin master
                    '';
                };
                interactiveShellInit = "set -l OMF_PATH /nix/store/lvdhqk4qpb9v2rvv3rwjc0540knpxsk5-source";
                plugins = [
                    # {
                    #     name = "oh-my-fish";
                    #     src = pkgs.fetchFromGitHub {
                    #       owner = "oh-my-fish";
                    #       repo = "oh-my-fish";
                    #       rev = "v7";
                    #       sha256 = "12qin0i6z7g6kyb3cahazd024jy3smmm161pich7zpmpb5sma8vq";
                    #     };
                    # }



                	# {
                	#     name = "theme-l";
                	#     src = pkgs.fetchFromGitHub {
                	#     	owner = "oh-my-fish";
                	#     	repo = "theme-l";
                	#     	rev = "master";
                	#     	sha256 = "1sjsnd4wn1zxail88liwplhfamqg2n0ihlivb2fv840r676f9ky3";
                	#     };
                	# }

                    # {
                    #     name = "fundle";
                    #     src = pkgs.fetchFromGitHub {
                    #       owner = "danhper";
                    #       repo = "fundle";
                    #       rev = "v0.7.0";
                    #       sha256 = "1i58hbvpjc7c7hi99hhvw5qmgjpcj1k7rij9mijpjiwi59ng72a2";
                    #     };
                    # }

                    # {
                    #     name = "fisher";
                    #     src = pkgs.fetchFromGitHub {
                    #       owner = "ThePonyCoder";
                    #       repo = "fisher";
                    #       rev = "master";
                    #       sha256 = "1d9kgfc0fmy7gwlavk6ibq478nyjyc2vmg59hfj3hq84ppma966y";
                    #     };
                    # }

                    {
                        name = "fish-plugins";
                        src = fetchGit {
                            url = "https://github.com/ThePonyCoder/fish-plugins.git";
                            ref = "master";
                            # owner = "ThePonyCoder";
                            # repo = "fish-plugins";
                            # rev = "master";
                          # sha256 = "1an12jj01p45d1rdj05bkw6nlchcrwkl04bg7bcgladm3hc8z9wh";
                        };
                    }

                    # {
                    #     name = "theme-qing";
                    #     src = pkgs.fetchFromGitHub {
                    #       owner = "oh-my-fish";
                    #       repo = "theme-qing";
                    #       rev = "master";
                    #       sha256 = "1nzi0sjj4j7pq3c20fblccrxqg6gwnrj85p4j1smsnwj6w2s4cxf";
                    #     };
                    # }


                ];
            };
        };
    };

    system.stateVersion = "20.03";
}
