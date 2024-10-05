from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta

# DAG 기본 설정
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),  # 시작 날짜를 과거로 설정하면 DAG가 활성화됨
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),  # 실패 시 5분 후 재시도
}

# DAG 생성
dag = DAG(
    'crawler_dag',
    default_args=default_args,
    description='A simple DAG to run crawler.py',
    schedule_interval='0 15 * * *',  # 매일 자정 (대한민국 기준 자정 UTC 15시)
)

# 크롤링 파일들 리스트
crawler_file_path_list = []

# BashOperator를 사용하여 Python 스크립트 실행
for file_path in crawler_file_path_list:
    run_crawler = BashOperator(
        task_id='run_crawler',
        bash_command=f'python3 ../{file_path}',  # crawler.py 파일 경로 설정
        dag=dag,
    )