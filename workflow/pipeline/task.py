"""
Task abstraction for a pipeline task
This is ideally a wrapper of an airflow operator with pipeline specific configurations
"""


class Task:

    operator = None  # type: None

    def __init__(self, config):
        self.config = config
        self.operator = None

    def get_operator(self):
        return self.operator


