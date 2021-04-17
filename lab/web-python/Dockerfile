FROM fedora
RUN dnf -y update && \
    dnf -y install python pip && \
    dnf clean all && \
    useradd runner
USER runner
COPY web-first.py /usr/local/bin/
RUN pip install flask --user
CMD ["python","/usr/local/bin/web-first.py"]