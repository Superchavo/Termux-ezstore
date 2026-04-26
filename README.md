# Termux-ezstore
This is a program for newbies if u dont want to pkg and do all that
---------------
first do ```bash pkg upgrade && pkg install wget yad root-repo tur-repo games-repo xfce4 tigervnc nano''' , then  vncserver :1 , put a password, then vncserver -kill :1 , then do nano ~/.vnc/xstartup , then remove everything and put exec xfce4-session , then vncserver :1 and also export DISPLAY=:1 , then install a vnc viewer, put 127.0.0.1 as the host, 5901 as the port, it might ask u a pass, put the pass u did when tigervnc told u, if u can put it on remember the password, then do  ```bash wget https://raw.githubusercontent.com/Superchavo/Termux-ezstore/refs/heads/main/termux-ezstore.sh && chmod +x ./termux-ezstore.sh && ./termux-ezstore.sh''' , and then enjoy!
Also if Termux asks about a 'configuration file', just press Enter to keep the default

if this breaks for u, create a issue


!!!!!!PLEASE DON PUT THIS CODE IN NORMAL DISTROS OR PROOT, IT WONT WORK!!!!!!
