from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta
from airflow.operators.docker_operator import DockerOperator

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

with DAG('docker_dag', default_args=default_args, schedule_interval=None, catchup=False) as dag:
        t1 = BashOperator(
                task_id='print_current_date',
                bash_command='date'
        )
    
        '''
        t2 = DockerOperator(
                task_id='docker_command',
                image='alpine',
                api_version='auto',
                auto_remove=True,
                command="touch `date '+%Y-%m-%d:%H-%M-%S'`",
                docker_conn_id="sam_reg",
                docker_url="tcp://192.168.1.107:2375",
                network_mode="bridge"
        )'''

        t2 = BashOperator(
                task_id='t2',
                bash_command='date'
        )

        t3 = BashOperator(
                task_id='t3',
                bash_command='date'
        )

        t4 = BashOperator(
                task_id='t4',
                bash_command='date'
        )

        t5 = BashOperator(
                task_id='print_hello',
                bash_command='echo "hello world"'
        )

        t1  >> [t2,t3,t4] >> t5
