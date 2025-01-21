FROM python:latest AS script
ENV SOLVER=https://gist.githubusercontent.com/chamlis/4d7441967787dc862f635a53958cabd6/raw/6062345673fd963d22f1eb0c1a82a5f8d09986f7/solve.py

RUN wget $SOLVER \
 && pwd \
 && ls -lah

FROM alpine:latest AS dl
ADD script.sh
RUN chmod +x script.sh && ./script.sh

FROM python:latest AS grabby
RUN pip install pulp
COPY --from=dl /tmp/repositories_data /repositories
COPY --from=script solve.py /solve.py
RUN  pwd \
 && ls -lah \
 && python /solve.py /repositories/* \
 && pwd \
 && ls -lah

FROM alpine:latest
COPY --from=grabby out packages.txt
RUN xargs -a packages.txt apk add
