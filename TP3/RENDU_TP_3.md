# TP3 : Cloud privé

# 1 : Architecture du lab : 

- Ping du ```kvm1.one``` depuis ```frontend.one``` : 
    ```

    ```

- Ping du ```kvm2.one``` depuis ```frontend.one``` : 
    ```

    ```

# 2. Setup 

## A. Frontend

### a. Database

- Installation du serveur MySQL : 
    ```
    [aflorian@frontend ~]$ wget https://dev.mysql.com/get/mysql80-community-release-el9-5.noarch.rpm

    [aflorian@frontend ~]$ sudo rpm -ivh mysql80-community-release-el9-5.noarch.rpm
    ```

- Installation du paquet qui contient le serveur MySQL : 
    ```
    [aflorian@frontend ~]$ dnf search mysql

    [aflorian@frontend ~]$ sudo dnf install mysql-community-server.x86_64
    ```

- Démmarage du serveur MySQL : 
    ```
    [aflorian@frontend ~]$ sudo systemctl start mysqld

    [aflorian@frontend ~]$ sudo systemctl enable mysqld
    ```

- Récupération du mot de passe temporaire : 
    ```
    [aflorian@frontend ~]$ sudo cat /var/log/mysqld.log | grep "temporary password"
    2025-09-16T08:19:31.559593Z 6 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: PRIVE

    ```

- Connexion à la base pour y effectuer les commandes SQL : 
    ```
    [aflorian@frontend ~]$ mysql -u root -p
    Enter password:
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 8
    Server version: 8.0.43

    Copyright (c) 2000, 2025, Oracle and/or its affiliates.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'PRIVE';
    Query OK, 0 rows affected (0.01 sec)

    mysql> CREATE USER 'oneadmin' IDENTIFIED BY 'PRIVE';
    Query OK, 0 rows affected (0.02 sec)

    mysql> CREATE DATABASE opennebula;
    Query OK, 1 row affected (0.01 sec)

    mysql> GRANT ALL PRIVILEGES ON opennebula.* TO 'oneadmin';
    Query OK, 0 rows affected (0.01 sec)

    mysql> SET GLOBAL TRANSACTION ISOLATION LEVEL READ COMMITTED;
    Query OK, 0 rows affected (0.00 sec)

    mysql> exit
    Bye
    ```

### b. OpenNebula

- Ajout des dépôts Open Nebula : 
    ```
    [aflorian@frontend ~]$ sudo nano /etc/yum.repos.d/opennebula.repo

    [opennebula]
    name=OpenNebula Community Edition
    baseurl=https://downloads.opennebula.io/repo/6.10/RedHat/$releasever/$basearch
    enabled=1
    gpgkey=https://downloads.opennebula.io/repo/repo2.key
    gpgcheck=1
    repo_gpgcheck=1

    [aflorian@frontend ~]$ sudo dnf makecache -y
    Extra Packages for Enterprise Linux 9 - x86_64                66 kB/s |  42 kB     00:00
    Extra Packages for Enterprise Linux 9 openh264 (From Cisco)  1.8 kB/s | 993  B     00:00
    MySQL 8.0 Community Server                                    16 kB/s | 3.0 kB     00:00
    MySQL Connectors Community                                    12 kB/s | 3.0 kB     00:00
    MySQL Tools Community                                         15 kB/s | 3.0 kB     00:00
    OpenNebula Community Edition                                 1.8 kB/s | 833  B     00:00
    OpenNebula Community Edition                                  17 kB/s | 3.1 kB     00:00
    Importing GPG key 0x906DC27C:
    Userid     : "OpenNebula Repository <contact@opennebula.io>"
    Fingerprint: 0B2D 385C 7C93 04B1 1A03 67B9 05A0 5927 906D C27C
    From       : https://downloads.opennebula.io/repo/repo2.key
    OpenNebula Community Edition                                 799 kB/s | 690 kB     00:00
    Rocky Linux 9 - BaseOS                                       8.6 kB/s | 4.1 kB     00:00
    Rocky Linux 9 - BaseOS                                       562 kB/s | 2.5 MB     00:04
    Rocky Linux 9 - AppStream                                    6.7 kB/s | 4.5 kB     00:00
    Rocky Linux 9 - Extras                                       4.4 kB/s | 2.9 kB     00:00
    Metadata cache created.
    ```
- Installation d'OpenNebula et de ses paquets : 
    ```
    [aflorian@frontend ~]$ sudo dnf install -y opennebula opennebula-sunstone opennebula-fireedge
    ```

- Configuration d'OpenNebula : 
    ```
    [aflorian@frontend ~]$ sudo nano /etc/one/oned.conf

    # Sample configuration for MySQL
    DB = [ BACKEND = "mysql",
       SERVER  = "localhost",
       PORT    = 0,
       USER    = "oneadmin",
       PASSWD  = "PRIVE",
       DB_NAME = "opennebula",
       CONNECTIONS = 25,
       COMPARE_BINARY = "no" ]
    ```

- Création du user pour se log sur la webUI OpenNebula : 
    ```
    [aflorian@frontend ~]$ sudo -i -u oneadmin
    [oneadmin@frontend ~]$ oneuser create toto super_password
    ID: 2
    [oneadmin@frontend ~]$ oneuser list
    ID NAME                ENAB GROUP    AUTH            VMS     MEMORY        CPU
    2 toto                yes  users    core        0 /   -      0M /   0.0 /   -
    1 serveradmin         yes  oneadmin server_c    0 /   -      0M /   0.0 /   -
    0 oneadmin            yes  oneadmin core              -          -          -
    [oneadmin@frontend ~]$ oneuser chgrp toto oneadmin
    ```

- Démmarage des services OpenNebula : 
    ```
    [aflorian@frontend ~]$ sudo systemctl start opennebula
    [aflorian@frontend ~]$ sudo systemctl start opennebula-sunstone
    [aflorian@frontend ~]$ sudo systemctl enable opennebula
    [aflorian@frontend ~]$ sudo systemctl enable opennebula-sunstone
    ```

### c. Conf système

- Ouverture firewall : 
    ```
    [aflorian@frontend ~]$ sudo firewall-cmd --permanent --add-port=9869/tcp
    success
    [aflorian@frontend ~]$ sudo firewall-cmd --permanent --add-port=22/tcp
    success
    [aflorian@frontend ~]$ sudo firewall-cmd --permanent --add-port=2633/tcp
    success
    [aflorian@frontend ~]$ sudo firewall-cmd --permanent --add-port=4124/tcp
    success
    [aflorian@frontend ~]$ sudo firewall-cmd --permanent --add-port=4124/udp
    success
    [aflorian@frontend ~]$ sudo firewall-cmd --permanent --add-port=29876/tcp
    success
    [aflorian@frontend ~]$ sudo firewall-cmd --reload
    success
    [aflorian@frontend ~]$ sudo firewall-cmd --list-ports
    22/tcp 2633/tcp 4124/tcp 4124/udp 9869/tcp 29876/tcp
    ```

## B. Noeuds KVM

### a. KVM

- Ajout du nested sur la VM kvm depuis le CLI du PC hôte :
    ```
    VBoxManage modifyvm kvm1 --nested-hw-virt on
    ```

- Ajout des dépôts supplémentaires :
    ```
    [aflorian@kvm1 ~]$ sudo nano /etc/yum.repos.d/opennebula.repo

    [opennebula]
    name=OpenNebula Community Edition
    baseurl=https://downloads.opennebula.io/repo/6.10/RedHat/$releasever/$basearch
    enabled=1
    gpgkey=https://downloads.opennebula.io/repo/repo2.key
    gpgcheck=1
    repo_gpgcheck=1

    [aflorian@kvm1 ~]$ wget https://dev.mysql.com/get/mysql80-community-release-el9-5.noarch.rpm
    [aflorian@kvm1 ~]$ sudo rpm -ivh mysql80-community-release-el9-5.noarch.rpm
    [aflorian@kvm1 ~]$ sudo dnf install -y epel-release
    ```

- Installation des libs MySQL : 
    ```
    [aflorian@kvm1 ~]$ sudo dnf install -y mysql-community-server
    ```

- Installation KVM : 
    ```
    [aflorian@kvm1 ~]$ sudo dnf install -y opennebula-node-kvm
    ```

- Installation des dépendances additionnelles : 
    ```
    [aflorian@kvm1 ~]$ sudo dnf install -y genisoimage
    ```

- Démarrage du service ```libvirtd``` : 
    ```
    [aflorian@kvm1 ~]$ sudo systemctl start libvirtd
    [aflorian@kvm1 ~]$ sudo systemctl enable libvirtd
    ```

### b. Système

- Ouverture du firewall : 
    ```
    [aflorian@kvm1 ~]$ sudo firewall-cmd --permanent --add-port=22/tcp
    success
    [aflorian@kvm1 ~]$ sudo firewall-cmd --permanent --add-port=8472/udp
    success
    ```

- Handle SSH : 
    ```
    [oneadmin@frontend ~]$ ls -l ~/.ssh/id_rsa ~/.ssh/id_rsa.pub
    -rw-------. 1 oneadmin oneadmin 2610 Sep 16 05:14 /var/lib/one/.ssh/id_rsa
    -rw-r--r--. 1 oneadmin oneadmin  575 Sep 16 05:14 /var/lib/one/.ssh/id_rsa.pub

    [oneadmin@frontend ~]$ ssh-copy-id oneadmin@10.3.1.11
    /bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/var/lib/one/.ssh/id_rsa.pub"
    /bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
    /bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
    oneadmin@10.3.1.11's password:

    Number of key(s) added: 1

    Now try logging into the machine, with:   "ssh 'oneadmin@10.3.1.11'"
    and check to make sure that only the key(s) you wanted were added.

    [oneadmin@frontend ~]$ ssh oneadmin@10.3.1.11
    Last failed login: Tue Sep 16 07:28:16 EDT 2025 from 10.3.1.10 on ssh:notty
    There were 9 failed login attempts since the last successful login.
    Last login: Mon Sep 15 15:00:45 2025 from 10.3.1.10
    [oneadmin@kvm1 ~]$
    ```

### c. Ajout des noeuds au cluster

La ```kvm1.one``` remonte bien en ```ON``` dans Infrastructures > Hosts

## C. Réseau

- Création et configuration du bridge Linux : 
    ```
    [aflorian@kvm1 ~]$ sudo ip link add name vxlan_bridge type bridge
    [aflorian@kvm1 ~]$ sudo ip link set dev vxlan_bridge up
    [aflorian@kvm1 ~]$ sudo ip addr add 10.220.220.201/24 dev vxlan_bridge
    [aflorian@kvm1 ~]$ sudo firewall-cmd --add-interface=vxlan_bridge --zone=public --permanent
    success
    [aflorian@kvm1 ~]$ sudo firewall-cmd --add-masquerade --permanent
    success
    [aflorian@kvm1 ~]$ sudo firewall-cmd --reload
    success
    ```

- Création du script vxlan.sh : 
    ```
    [aflorian@kvm1 ~]$ ls /opt
    vxlan.sh
    [aflorian@kvm1 ~]$ cat /etc/systemd/system/vxlan.service
    [Unit]
    Description=Setup VXLAN interface for ONE

    [Service]
    Type=oneshot
    RemainAfterExit=yes
    ExecStart=/bin/bash /opt/vxlan.sh

    [Install]
    WantedBy=multi-user.target

    [aflorian@kvm1 ~]$ sudo systemctl daemon-reload
    [aflorian@kvm1 ~]$ sudo systemctl start vxlan
    [aflorian@kvm1 ~]$ sudo systemctl enable vxlan
    Created symlink /etc/systemd/system/multi-user.target.wants/vxlan.service → /etc/systemd/system/vxlan.service.
    [aflorian@kvm1 ~]$ sudo systemctl status vxlan
    ● vxlan.service - Setup VXLAN interface for ONE
        Loaded: loaded (/etc/systemd/system/vxlan.service; enabled; preset: disabl>
        Active: active (exited) since Tue 2025-09-16 09:56:52 EDT; 16s ago
    Main PID: 14963 (code=exited, status=0/SUCCESS)
            CPU: 358ms

    Sep 16 09:56:51 kvm1.one systemd[1]: Starting Setup VXLAN interface for ONE...
    Sep 16 09:56:51 kvm1.one bash[14964]: RTNETLINK answers: File exists
    Sep 16 09:56:51 kvm1.one bash[14966]: Error: ipv4: Address already assigned.
    Sep 16 09:56:51 kvm1.one bash[14967]: Warning: ALREADY_ENABLED: vxlan_bridge
    Sep 16 09:56:51 kvm1.one bash[14967]: success
    Sep 16 09:56:51 kvm1.one bash[14971]: Warning: ALREADY_ENABLED: masquerade
    Sep 16 09:56:51 kvm1.one bash[14971]: success
    Sep 16 09:56:52 kvm1.one bash[14972]: success
    Sep 16 09:56:52 kvm1.one systemd[1]: Finished Setup VXLAN interface for ONE.
    ```

# 3. Utilisation de la plateforme

## A. Ajout clé publique de la machine ```frontend.one``` dans OpenNebula

Pour cela, il faut récupérer dans le homedir de l'utilisateur ```oneadmin``` sa clé publique : ```~/.ssh/id_rsa.pub```, puis la déposer dans la WebUI de OpenNebula, dans ```Settings > Onglet Auth```

## B. Récupération de l'image Rocky Linux 9

Pour cela, il faut naviguer dans l'interface WebUI de OpenNebula, se rendre sur ```Storage > Apps```, chercher l'image de Rocky Linux 9, et le télécharger dans ```frontend.one``` via le bouton ```Import into Datastore```

## C. Création de la VM

Pour cela, sur l'interface WebUI de OpenNebula, se rendre sur ```Instances > VMs```, et créer une VM.

Il faut pour cela sélectionner le template proposé avec l'image Rocky Linux 9, donner un nom à la VM, ajouter le network VXLAN que nous avons créé, l'ajouter au groupe de sécurté proposé, et activer la connexion SSH.

## D. Test de la connectivité à la VM

- Ping depuis le noeud ```kvm1.one``` vers l'IP de la VM créé (visible depuis l'interface WebUI) : 
    ```
    [aflorian@kvm1 ~]$ ping 10.220.220.1
    PING 10.220.220.1 (10.220.220.1) 56(84) bytes of data.
    64 bytes from 10.220.220.1: icmp_seq=1 ttl=64 time=0.554 ms
    64 bytes from 10.220.220.1: icmp_seq=2 ttl=64 time=2.58 ms
    ^C
    --- 10.220.220.1 ping statistics ---
    2 packets transmitted, 2 received, 0% packet loss, time 1043ms
    rtt min/avg/max/mdev = 0.554/1.565/2.577/1.011 ms
    ```

- Connexion en SSH via la clé de ```oneadmin``` : 
    ```
    [aflorian@frontend ~]$ sudo su - oneadmin
    [oneadmin@frontend ~]$ eval $(ssh-agent)
    Agent pid 2258
    [oneadmin@frontend ~]$ ssh-add
    Identity added: /var/lib/one/.ssh/id_rsa (oneadmin@frontend.one)
    [oneadmin@frontend ~]$ ssh -J kvm1 root@10.220.220.100
    kex_exchange_identification: Connection closed by remote host
    Connection closed by UNKNOWN port 65535
    [oneadmin@frontend ~]$ ssh -J kvm1 root@10.220.220.1
    Warning: Permanently added '10.220.220.1' (ED25519) to the list of known hosts.
    Activate the web console with: systemctl enable --now cockpit.socket

    [root@localhost ~]# 
    ```

## E. Permettre l'accès à internet sur la VM

- Ajout de l'IP du bridge VXLAN de la machine hôte comme route par défaut pour avoir internet : 
    ```
    [root@localhost ~]# ip route add default via 10.220.220.201
    [root@localhost ~]# ping 1.1.1.1
    PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
    64 bytes from 1.1.1.1: icmp_seq=1 ttl=254 time=16.7 ms
    64 bytes from 1.1.1.1: icmp_seq=2 ttl=254 time=16.4 ms
    ^C
    --- 1.1.1.1 ping statistics ---
    2 packets transmitted, 2 received, 0% packet loss, time 1003ms
    rtt min/avg/max/mdev = 16.443/16.564/16.686/0.121 ms
    ```

# 4. Ajout d'un noeud et VXLAN

## A. Ajout d'un noeud

Pour la configuration de ```kvm2.one```, j'ai tout d'abord cloné le ```kvm1.one```, puis j'ai changé l'IP statique de la VM, lIP pour le bridge également, et une fois qu'il est ajouté dans la WebUI, nous pouvons le retrouver avec la commande suivante : 
```
[oneadmin@frontend ~]$ onehost list
ID NAME              CLUSTER    TVM      ALLOCATED_CPU      ALLOCATED_MEM STAT
2 kvm2.one          default      0       0 / 100 (0%)     0K / 1.7G (0%) on
1 kvm1.one          default      1   100 / 100 (100%)  768M / 1.7G (43%) on
```

## B. VM sur le deuxième noeud

Après avoir créé la VM sur la WebUI, en spécifiant de la faire tourner sur ```kvm2.one```, on arrive à s'y connecter en ssh :
```
[oneadmin@frontend ~]$ ssh -J kvm2 root@10.220.220.2
Warning: Permanently added '10.220.220.2' (ED25519) to the list of known hosts.
Activate the web console with: systemctl enable --now cockpit.socket

[root@localhost ~]#
```

## C. Connectivité entre les VMs

Les deux VMs arrivent donc  à se ping : 
```
[root@localhost ~]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
    valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 02:00:0a:dc:dc:01 brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    altname ens3
    inet 10.220.220.1/24 brd 10.220.220.255 scope global noprefixroute eth0
    valid_lft forever preferred_lft forever
    inet6 fe80::aff:fedc:dc01/64 scope link
    valid_lft forever preferred_lft forever
[root@localhost ~]# ping 10.220.220.2
PING 10.220.220.2 (10.220.220.2) 56(84) bytes of data.
64 bytes from 10.220.220.2: icmp_seq=1 ttl=64 time=0.982 ms
64 bytes from 10.220.220.2: icmp_seq=2 ttl=64 time=0.880 ms
```

## D. Inspection du traffic

Installation de ```tcpdump``` : 
```
[aflorian@kvm1 ~]$ sudo dnf install -y tcpdump
Last metadata expiration check: 0:54:16 ago on Wed Sep 17 14:25:20 2025.
Dependencies resolved.
================================================================================
Package         Architecture   Version                 Repository         Size
================================================================================
Installing:
tcpdump         x86_64         14:4.99.0-9.el9         appstream         542 k
```

Capture du trafic et analyse des deux captures réalisées : 
```
[aflorian@kvm1 ~]$ sudo tcpdump -i enp0s8 -w yop.pcap
dropped privs to tcpdump
tcpdump: listening on enp0s8, link-type EN10MB (Ethernet), snapshot length 262144 bytes
^C113 packets captured
120 packets received by filter
0 packets dropped by kernel
[aflorian@kvm1 ~]$ sudo tcpdump -i vxlan_bridge -w yo.pcap
dropped privs to tcpdump
tcpdump: listening on vxlan_bridge, link-type EN10MB (Ethernet), snapshot length 262144 bytes
^C16 packets captured
16 packets received by filter
0 packets dropped by kernel
[aflorian@kvm1 ~]$ ls
mysql80-community-release-el9-5.noarch.rpm  yo.pcap  yop.pcap
[aflorian@kvm1 ~]$ tcpdump -r yo.pcap
15:23:41.850234 IP kvm1.one.48672 > 10.220.220.1.ssh: Flags [.], ack 100, win 548, options [nop,nop,TS val 3799375880 ecr 2932033378], length 0
15:23:42.850891 IP 10.220.220.1 > 10.220.220.2: ICMP echo request, id 8, seq 10, length 64
15:23:42.851361 IP 10.220.220.2 > 10.220.220.1: ICMP echo reply, id 8, seq 10, length 64
15:23:42.851619 IP 10.220.220.1.ssh > kvm1.one.48672: Flags [P.], seq 100:200, ack 1, win 249, options 
[aflorian@kvm1 ~]$ tcpdump -r yop.pcap
15:23:20.783269 IP frontend.one.47922 > kvm1.one.ssh: Flags [.], ack 373, win 476, options [nop,nop,TS val 1196016847 ecr 130336109], length 0
15:23:20.869915 IP kvm1.one.ssh > frontend.one.47922: Flags [P.], seq 373:457, ack 488, win 666, options [nop,nop,TS val 130336196 ecr 1196016933], length 84
15:23:20.870335 IP frontend.one.47922 > kvm1.one.ssh: Flags [.], ack 457, win 476, options [nop,nop,TS val 1196016934 ecr 130336196], length 0
15:23:20.870616 IP frontend.one.ssh > _gateway.63247: Flags [P.], seq 193:257, ack 256, win 511, length 64
15:23:20.912182 IP _gateway.63247 > frontend.one.ssh: Flags [.], ack 257, win 511, length 0
15:23:21.057864 IP _gateway.63247 > frontend.one.ssh: Flags [P.], seq 256:320, ack 257, win 511, length 64
15:23:21.058448 IP frontend.one.47922 > kvm1.one.ssh: Flags [P.], seq 488:572, ack 457, win 476, options [nop,nop,TS val 1196017122 ecr 130336196], length 84
15:23:21.059224 IP kvm1.one.ssh > frontend.one.47922: Flags [P.], seq 457:541, ack 572, win 666, options [nop,nop,TS val 130336386 ecr 1196017122], length 84
15:23:21.059605 IP frontend.one.47922 > kvm1.one.ssh: Flags [.], ack 541, win 476, options [nop,nop,TS val 1196017124 ecr 130336386], length 0
```

