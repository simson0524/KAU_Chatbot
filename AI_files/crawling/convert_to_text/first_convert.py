import subprocess

subprocess.run(['python', 'crawling/convert_to_text/combin_yozeum.py'], check=True)

subprocess.run(['python', 'crawling/convert_to_text/dreamspon_convert.py'], check=True)
subprocess.run(['python', 'crawling/convert_to_text/yozeumgeotdeul_convert.py'], check=True)
subprocess.run(['python', 'crawling/convert_to_text/school_convert.py'], check=True)

subprocess.run(['python', 'crawling/convert_to_text/combin_website_csv.py'], check=True)