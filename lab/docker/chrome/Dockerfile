# xhost +
# docker run --rm --privileged -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix --network host <IMAGE>
FROM ubuntu:22.04
RUN  apt update && \ 
     export DEBIAN_FRONTEND=noninteractive && \ 
     apt install curl -y && \
     apt update && \
     curl -sLO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
     apt install ./google-chrome-stable_current_amd64.deb -y && \
     apt --fix-broken install && \
     apt clean && \
     apt autoclean && \
     useradd -m lab
USER lab
CMD ["/usr/bin/google-chrome"]