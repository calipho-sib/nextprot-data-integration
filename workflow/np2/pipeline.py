from builtins import range
from datetime import timedelta, datetime

import airflow
from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.docker_operator import DockerOperator

# NP2 pipeline will have pre-processing step which reads the source files and transform into statements and a ETL
# components which does the ETL processing
# This pipeline will execute the pre-processing step in parallel and ETL steps in parallel

default_args = {
    'owner': 'airflow',
    'description': 'Use of the DockerOperator',
    'depend_on_past': False,
    'start_date': datetime(2018, 1, 3),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}

# Initializes the dag according to the input dataset
# Basically it generates the tasks to be run in parallel based on the number of data points to process
def init():
    return 0;

def build_parallel_tasks(tasks):
    import_tasks = []
    load_tasks = []

    for task_id in range(0, tasks):
        # Generate import tasks
        task_id = "ensembl_import_" + str(task_id)
        ant_input = "-Dids.file=ids-ensembl-" + str(task_id) + ".txt"
        ant_task = "import-ensembl-variant-by-batch"
        command = ant_command + ant_input + ant_task
        import_tasks << build_docker_task(task_id, command)

        # Generate load tasks
        task_id = "ensembl_load_" + str(task_id)
        ant_input = "-Dxml.filename="
        ant_task = "db-load-ensembl"
        command = ant_command + ant_input + ant_task
        load_tasks << build_docker_task(task_id, command)

     return import_tasks, load_tasks

# Generates the import tasks by dividing the input entries
def build_docker_task(task_id, command):
    return DockerOperator(
            task_id=task_id,
            image='np.perl:latest',
            api_version='auto',
            auto_remove=True,
            command=command,
            docker_url="unix://var/run/docker.sock",
            network_mode="bridge")

# Build parallel import and load tasks
import_tasks, load_tasks = build_parallel_tasks(5)

with DAG('docker_dag', default_args=default_args, schedule_interval="5 * * * *", catchup=False) as dag:
    t1 = BashOperator(
        task_id='ENS4 init',
        bash_command='echo Initializing ENS4',
        dag=dag
    )

    t1 >> import_tasks >> load_tasks


