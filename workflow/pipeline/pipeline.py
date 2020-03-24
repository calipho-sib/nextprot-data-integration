from task import Task

"""
Abstraction for a pipeline
This is a wrapper of an airflow dag, with specific configuration
"""
class Pipeline:

    def __init__(self, config):
        self.config = config
        self.tasks = []
        tasks_configs = config.get_task_configs()

        for tasks_config in tasks_configs:
            self.tasks.push(Task(tasks_config))

    """
    Generates the dag, which will then be processed by the airflow scheduler
    """
    def generate_airflow_dag(self):
        for task in self.tasks:


    """
    Generates a airflow operator representing a task in the dag 
    """
    def generate_airflow_task(self):




