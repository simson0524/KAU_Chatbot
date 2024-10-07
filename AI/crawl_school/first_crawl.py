import academic_notice_url
import academic_research_url
import epidemic_notice_url
import event_notice_url
import general_notice_url
import IT_notice_url
import recruitment_url
import scholarloan_notice_url
import Merge_URL
import school_crawling
import html_img_to_text
import combined_text

# academic_notice_url.crawl_academic_notice()
# academic_research_url.crawl_academic_research()
# epidemic_notice_url.crawl_epidemic_notice()
# event_notice_url.crawl_event_notice()
# general_notice_url.crawl_general_notice()
IT_notice_url.crawl_IT_notice()
# recruitment_url.crawl_recruitment()
# scholarloan_notice_url.crawl_scholarloan_notice()

Merge_URL.merge_urls()

school_crawling.school_crawling()

html_img_to_text.to_text()

combined_text.combine_text()