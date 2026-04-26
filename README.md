# Termux-ezstore
This is a program for newbies if u dont want to pkg and do all that
---------------
first do pkg upgrade && pkg install wget yad root-repo tur-repo games-repo xfce4 tigervnc nano , then vncserver :1 , put a password, then vncserver -kill :1 , then do nano ~/.vnc/xstartup , then remove everything and put exec xfce4-session , then vncserver :1 and also export DISPLAY=:1 ,
then do wget https://raw.githubusercontent.com/Superchavo/Termux-ezstore/refs/heads/main/termux-ezstore.sh && chmod +x 
then do ./termux-ezstore and enjoy!
