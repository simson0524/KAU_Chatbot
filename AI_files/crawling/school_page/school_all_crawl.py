import subprocess

subprocess.run(['python', 'crawling/school_page/update/academic_notice_url_update.py'], check=True)
subprocess.run(['python', 'crawling/school_page/update/academic_research_url_update.py'], check=True)
subprocess.run(['python', 'crawling/school_page/update/epidemic_notice_url_update.py'], check=True)
subprocess.run(['python', 'crawling/school_page/update/event_notice_url_update.py'], check=True)
subprocess.run(['python', 'crawling/school_page/update/general_notice_url_update.py'], check=True)
subprocess.run(['python', 'crawling/school_page/update/IT_notice_url_update.py'], check=True)
subprocess.run(['python', 'crawling/school_page/update/recruitment_url_update.py'], check=True)
subprocess.run(['python', 'crawling/school_page/update/scholarloan_notice_url_update.py'], check=True)

subprocess.run(['python', 'crawling/school_page/update/Merge_URL.py'], check=True)

subprocess.run(['python', 'crawling/school_page/update/school_crawling_update.py'], check=True)

subprocess.run(['python', 'crawling/school_page/update/del_csv.py'], check=True)