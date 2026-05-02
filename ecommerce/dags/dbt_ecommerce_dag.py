from datetime import datetime, timedelta
from airflow.sdk import dag, task
from airflow.operators.bash import BashOperator

DBT_PROJECT_DIR = "/opt/dbt/ecommerce"

default_args = {
    "owner": "data_team",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

@dag(
    schedule="0 2 * * *",  # Daily at 2:00 AM
    start_date=datetime(2026, 1, 1),
    catchup=False,
    default_args=default_args,
    description="Orchestrates the ecommerce ELT pipeline: dbt run, test, and snapshot",
    tags=["dbt", "ecommerce", "elt"],
)
def ecommerce_elt_pipeline():

    run_dbt_models = BashOperator(
        task_id="run_dbt_models",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt run",
    )

    test_dbt_models = BashOperator(
        task_id="test_dbt_models",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt test",
    )

    snapshot_dbt_models = BashOperator(
        task_id="snapshot_dbt_models",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt snapshot",
    )

    generate_dbt_docs = BashOperator(
        task_id="generate_dbt_docs",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt docs generate",
    )

    # Task dependencies: run → test → snapshot → docs
    run_dbt_models >> test_dbt_models >> snapshot_dbt_models >> generate_dbt_docs

ecommerce_elt_pipeline()