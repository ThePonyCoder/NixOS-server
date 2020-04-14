
{ config, pkgs, ... }:

{
    imports =[ ./hardware-configuration.nix ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "nixos";

    time.timeZone = "Europe/Minsk";

    programs = {
        fish.enable = true;
    };

    environment.systemPackages = with pkgs; [
        # system
        wget
        git
        htop
        neofetch

        # server
        screen
        transmission
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
    # networking.firewall.allowPing = true;
    # networking.firewall.allowedTCPPorts = [445 139];
    # networking.firewall.allowedUDPPorts = [445 139];



    users.extraUsers.user = {
        isNormalUser = true;
        home = "/home/user";
        createHome = true;
        extraGroups = [ "wheel" "networkmanager" ];
        uid = 1000;
        shell = "/run/current-system/sw/bin/fish";
    };


    system.stateVersion = "19.09";
}
