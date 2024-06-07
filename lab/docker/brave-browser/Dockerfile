# /usr/bin/brave-browser-stable --no-sandbox
# xhost +
# docker run --rm --privileged -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix --network host <IMAGE>
FROM ubuntu:22.04
RUN  apt update && \ 
     export DEBIAN_FRONTEND=noninteractive && \ 
     apt install curl -y && \
     curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && \
     echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|tee /etc/apt/sources.list.d/brave-browser-release.list && \
     apt update && \
     apt install brave-browser -y && \
     apt clean && \
     apt autoclean && \
     useradd -m lab
USER lab
CMD ["/usr/bin/brave-browser-stable"]