FROM python:3.8-buster

COPY resource/requirements.txt /tmp/requirements.txt
RUN cd /tmp \
    && pip install --upgrade pip \
    && pip install -r requirements.txt \
    && rm requirements.txt

CMD ["python", "-V"]