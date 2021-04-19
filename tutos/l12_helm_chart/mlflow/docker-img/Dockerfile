FROM python:3.8.9-buster

RUN pip install shap==0.39.0 && \
    pip install psycopg2-binary==2.8.6 && \
    pip install boto3==1.17.19 && \
    pip install mlflow[extras]==1.14.1

ENTRYPOINT ["mlflow", "server"]