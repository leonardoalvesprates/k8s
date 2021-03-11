FROM fedora
RUN dnf -y update && dnf -y install python pip && pip install flask --user
COPY web-first.py /usr/local/bin/
RUN chmod 755 /usr/local/bin/web-first.py
CMD ["python","/usr/local/bin/web-first.py"]