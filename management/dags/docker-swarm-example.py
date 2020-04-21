from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta
from airflow.operators.docker_operator import DockerOperator
from airflow.contrib.operators.docker_swarm_operator import DockerSwarmOperator

default_args = {
        'owner'                 : 'airflow',
        'description'           : 'Use of the DockerOperator',
        'depend_on_past'        : False,
        'start_date'            : datetime(2018, 1, 3),
        'email_on_failure'      : False,
        'email_on_retry'        : False,
        'retries'               : 1,
        'retry_delay'           : timedelta(minutes=5)
}

with DAG('docker_swarm_dag', default_args=default_args, schedule_interval=None, catchup=False) as dag:
        t1 = BashOperator(
                task_id='print_current_date',
                bash_command='date'
        )
    
        t2 = DockerSwarmOperator(
            api_version='auto',                # Docker API version
            docker_url='tcp://192.168.1.107:2375', # Set your docker URL
            command='/bin/sleep 10',           # Command you want to run in the container
            image='alpine:latest',             # The base image to use for running the container
            auto_remove=True,                  # Cleanup the container (and Docker service) once completed
            task_id='docker_t2',        # Unique task ID required by Airflow
            docker_conn_id="sam_reg"
        )

        t3 = DockerSwarmOperator(
            api_version='auto',                # Docker API version
            docker_url='tcp://192.168.1.107:2375', # Set your docker URL
            command='/bin/sleep 100',           # Command you want to run in the container
            image='alpine:latest',             # The base image to use for running the container
            auto_remove=True,                  # Cleanup the container (and Docker service) once completed
            task_id='docker_t3',        # Unique task ID required by Airflow
            docker_conn_id="sam_reg"
        )

        t4 = BashOperator(
                task_id='finish',
                bash_command='echo \'done\''
        )

        t1 >> [t2, t3] >> t4