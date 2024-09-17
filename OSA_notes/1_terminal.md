
Check which shell you are using

```
┌──(kali㉿kali)-[~]
└─$ echo $0        
/usr/bin/zsh
```

Change the shell

```
┌──(kali㉿kali)-[~]
└─$ chsh -s /usr/bin/bash
Password: 



┌──(kali㉿kali)-[~]
└─$ echo $0              
/usr/bin/zsh

but 

cat /etc/passwd

kali:x:1000:1000:,,,:/home/kali:/usr/bin/bash
kong:x:1001:1001:Kong default user:/home/kong:/bin/sh
                        
```

### Environment variable

Used by processes, example is path.
Editable and settable by users 

#####  `printenv` command

Dumps the environment variables in the current session

```
──(kali㉿kali)-[~/CHALLENGE]
└─$ printenv                                         
COLORFGBG=15;0
COLORTERM=truecolor
COMMAND_NOT_FOUND_INSTALL_PROMPT=1
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
DESKTOP_SESSION=lightdm-xsession
DISPLAY=:0.0
DOTNET_CLI_TELEMETRY_OPTOUT=1
GDMSESSION=lightdm-xsession
GTK_MODULES=gail:atk-bridge
HOME=/home/kali
LANG=en_US.UTF-8
LANGUAGE=
LOGNAME=kali
PANEL_GDK_CORE_DEVICE_EVENTS=0
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games
POWERSHELL_TELEMETRY_OPTOUT=1
POWERSHELL_UPDATECHECK=Off
PWD=/home/kali/CHALLENGE
QT_ACCESSIBILITY=1
QT_AUTO_SCREEN_SCALE_FACTOR=0
QT_QPA_PLATFORMTHEME=qt5ct
SESSION_MANAGER=local/kali:@/tmp/.ICE-unix/922,unix/kali:/tmp/.ICE-unix/922
SHELL=/usr/bin/zsh
SSH_AGENT_PID=1024
SSH_AUTH_SOCK=/tmp/ssh-IyJA1NsRJ0E6/agent.922
TERM=xterm-256color
USER=kali
WINDOWID=0
XAUTHORITY=/home/kali/.Xauthority
XDG_CONFIG_DIRS=/etc/xdg
XDG_CURRENT_DESKTOP=XFCE
XDG_DATA_DIRS=/usr/share/xfce4:/usr/local/share/:/usr/share/:/usr/share
XDG_GREETER_DATA_DIR=/var/lib/lightdm/data/kali
XDG_MENU_PREFIX=xfce-
XDG_RUNTIME_DIR=/run/user/1000
XDG_SEAT=seat0
XDG_SEAT_PATH=/org/freedesktop/DisplayManager/Seat0
XDG_SESSION_CLASS=user
XDG_SESSION_DESKTOP=lightdm-xsession
XDG_SESSION_ID=2
XDG_SESSION_PATH=/org/freedesktop/DisplayManager/Session0
XDG_SESSION_TYPE=x11
XDG_VTNR=7
_JAVA_OPTIONS=-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true
SHLVL=1
OLDPWD=/home/kali
LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.avif=01;35:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.crdownload=00;90:*.dpkg-dist=00;90:*.dpkg-new=00;90:*.dpkg-old=00;90:*.dpkg-tmp=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:*.swp=00;90:*.tmp=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90::ow=30;44:
LESS_TERMCAP_mb=
LESS_TERMCAP_md=                                                                             
LESS_TERMCAP_me=                                                                             
LESS_TERMCAP_so=
LESS_TERMCAP_se=                                                                             
LESS_TERMCAP_us=
LESS_TERMCAP_ue=                                                                             
IP=192.168.178.40
_=/usr/bin/printenv


```


##### Changing an environment variable (using export)
This allows a variable to persist beyond processes

```
┌──(kali㉿kali)-[~/CHALLENGE]
└─$ export IP=8.8.8.8
                                                                           

┌──(kali㉿kali)-[~/CHALLENGE]
└─$ echo $IP         
8.8.8.8
                                                                           

┌──(kali㉿kali)-[~/CHALLENGE]
└─$ ping -c4 $IP     
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=255 time=11.8 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=255 time=14.1 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=255 time=12.0 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=255 time=11.8 ms

--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3002ms
rtt min/avg/max/mdev = 11.788/12.400/14.059/0.959 ms
                                                                           

┌──(kali㉿kali)-[~/CHALLENGE]
└─$ bash               
┌──(kali㉿kali)-[~/CHALLENGE]
└─$ ping -c4 $IP
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=255 time=13.8 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=255 time=11.5 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=255 time=11.9 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=255 time=11.6 ms

--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3072ms
rtt min/avg/max/mdev = 11.507/12.221/13.823/0.936 ms

┌──(kali㉿kali)-[~/CHALLENGE]
└─$ 


```


##### Using a file as an environment variable
```
┌──(kali㉿kali)-[~/OSA/terminal]
└─$ export FILE=$PWD/file.txt 
  

┌──(kali㉿kali)-[~/OSA/terminal]
└─$ cat $FILE
whateva bro
```

##### Changing the path so that it checks the current working directory first in this case overriding the whoami command

```
┌──(kali㉿kali)-[~/OSA/terminal]
└─$ whoami
kali
                        

┌──(kali㉿kali)-[~/OSA/terminal]
└─$ ./whoami
not sure!
                                        

┌──(kali㉿kali)-[~/OSA/terminal]
└─$ export PATH=$PWD:$PATH   
                                       

┌──(kali㉿kali)-[~/OSA/terminal]
└─$ whoami
not sure!
                     

┌──(kali㉿kali)-[~/OSA/terminal]
└─$ 

```

##### Making environment variables persist across sessions

You need to add a function to the ~/.zhrc to save $IP in every new session when the session opens

```bash
# Load IP from file if it exists
if [ -f "$HOME/.ip_address" ]; then
  export IP=$(cat "$HOME/.ip_address")
fi

function ipt() {
  if [ -n "$1" ]; then
    export IP="$1"
    echo "$IP" > "$HOME/.ip_address"
    echo "IP variable set to: $IP"
  else
    if [ -z "$IP" ]; then
      echo "IP variable is not set."
      read -p "Enter the IP address: " IP
      export IP
      echo "$IP" > "$HOME/.ip_address"
      echo "IP variable set to: $IP"
    else
      echo "$IP"
    fi
  fi
}

```


##### tr command

Delete all newlines
```
┌──(kali㉿kali)-[~/OSA/terminal]
└─$ tr -d '\n' < x.txt      
┌──(kali㉿kali)-[~/OSA/terminal]
└─$ tr -d '\n' < x.txt      
===================================================================================Nmap====nmap -p- -sT -sV -A $IPnmap -p- -sC -sV $IP --opennmap -p- --script=vuln $IPnmap $IP -A -sCV -Pn #useif host seems down (pN assumes the target is up)###HTTP-Methodsnmap --script http-methods --script-args http-methods.url-path='/website' ###  --script smb-enum-sharessed IPs:grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' FILE===================================================================================WPScan & SSLwpscan --url $URL --disable-tls-checks --enumerate p --enumerate t --enumerate u===WPSca```
```

Change all text to capitals
```
┌──(kali㉿kali)-[~/OSA/terminal]
└─$ tr 'a-z' 'A-Z' < x.txt 

================================================================================
===NMAP====
NMAP -P- -ST -SV -A $IP
NMAP -P- -SC -SV $IP --OPEN
NMAP -P- --SCRIPT=VULN $IP
NMAP $IP -A -SCV -PN #USEIF HOST SEEMS DOWN (PN ASSUMES THE TARGET IS UP)


###HTTP-METHODS
NMAP --SCRIPT HTTP-METHODS --SCRIPT-ARGS HTTP-METHODS.URL-PATH='/WEBSITE' 
###  --SCRIPT SMB-ENUM-SHARES
SED IPS:
GREP -OE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' FILE

================================================================================
===WPSCAN & SSL
WPSCAN --URL $URL --DISABLE-TLS-CHECKS --ENUMERATE P --ENUMERATE T --ENUMERATE U

```

##### Save error to file

```
┌──(kali㉿kali)-[~/OSA/terminal]
└─$ cat nonexisting 2>error.txt 
                                                                                                                          

┌──(kali㉿kali)-[~/OSA/terminal]
└─$ cat error.txt              
cat: nonexisting: No such file or directory

```

##### Ignore error message

```
┌──(kali㉿kali)-[~/OSA/terminal]
└─$ cat nonexisting 2>/dev/null

```

##### grepping with -v to exclude substrings

```
┌──(kali㉿kali)-[~/OSA/terminal]
└─$ grep -v nologin /etc/passwd
root:x:0:0:root:/root:/usr/bin/zsh
sync:x:4:65534:sync:/bin:/bin/sync
tss:x:101:104:TPM software stack,,,:/var/lib/tpm:/bin/false
speech-dispatcher:x:108:29:Speech Dispatcher,,,:/run/speech-dispatcher:/bin/false
lightdm:x:110:112:Light Display Manager:/var/lib/lightdm:/bin/false
mysql:x:117:120:MariaDB Server,,,:/nonexistent:/bin/false
Debian-snmp:x:120:123::/var/lib/snmp:/bin/false
postgres:x:130:132:PostgreSQL administrator,,,:/var/lib/postgresql:/bin/bash
kali:x:1000:1000:,,,:/home/kali:/usr/bin/zsh
kong:x:1001:1001:Kong default user:/home/kong:/bin/sh

```

##### grepping with -v Extended
Exclude all of 3 options
```
┌──(kali㉿kali)-[~/OSA/terminal]
└─$ grep -v -E "false|nologin|sync" /etc/passwd
root:x:0:0:root:/root:/usr/bin/zsh
postgres:x:130:132:PostgreSQL administrator,,,:/var/lib/postgresql:/bin/bash
kali:x:1000:1000:,,,:/home/kali:/usr/bin/zsh
kong:x:1001:1001:Kong default user:/home/kong:/bin/sh

```

##### grepping to find keywords
Grep r=recursively for o=only the matching w=word i=case insensitive n=showlines
```
┌──(kali㉿kali)-[~/OSA/terminal]
└─$ grep -rowin 'password' / 2>/dev/null
/opt/microsoft/powershell/7/Microsoft.PowerShell.Security.xml:29:password
/opt/microsoft/powershell/7/Microsoft.PowerShell.Security.xml:673:Password
/opt/microsoft/powershell/7/Microsoft.PowerShell.Security.xml:675:password
/opt/microsoft/powershell/7/Microsoft.PowerShell.Security.xml:680:password
/opt/microsoft/powershell/7/Microsoft.PowerShell.Security.xml:849:password
/opt/microsoft/powershell/7/System.Management.Automation.xml:23817:Password

```

#### Setting up an alias command

```
┌──(kali㉿kali)-[~/OSA/terminal]
└─$ alias ipconfig=ifconfig
                                                                                                                          

┌──(kali㉿kali)-[~/OSA/terminal]
└─$ ipconfig   
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.0.2.15  netmask 255.255.255.0  broadcast 10.0.2.255
        inet6 fd00::1936:95f3:1f40:af15  prefixlen 64  scopeid 0x0<global>
        inet6 fe80::3ff5:b601:d170:4d5b  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:c1:97:54  txqueuelen 1000  (Ethernet)
        RX packets 1017020  bytes 808815760 (771.3 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 491519  bytes 29684221 (28.3 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 4  bytes 240 (240.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 4  bytes 240 (240.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

``` 

Kai feeding

11:15 240ml

5:18 240ml + vomit
