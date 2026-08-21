FROM --platform=linux/amd64 kalilinux/kali-rolling:latest

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update -y && apt install -y gnupg wget curl && \
    apt install --no-install-recommends -y \
    xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify \
    sudo xterm dbus-x11 x11-utils x11-xserver-utils x11-apps \
    net-tools git tzdata
RUN apt install -y kali-tools-top10

RUN touch /root/.Xauthority
EXPOSE 8080
CMD bash -c "vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE :1 && websockify --web=/usr/share/novnc/ ${PORT:-8080} localhost:5901"
