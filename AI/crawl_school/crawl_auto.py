import academic_notice_url_update
import academic_research_url_update
import epidemic_notice_url_update
import event_notice_url_update
import general_notice_url_update
import IT_notice_url_update
import recruitment_url_update
import scholarloan_notice_url_update
import Merge_URL
import school_crawling_update
import html_img_to_text
import combined_text

# academic_notice_url_update.crawl_academic_notice_update()
# academic_research_url_update.crawl_academic_research_update()
# epidemic_notice_url_update.crawl_epidemic_notice_update()
# event_notice_url_update.crawl_event_notice_update()
# general_notice_url_update.crawl_general_notice_update()
IT_notice_url_update.crawl_IT_notice_update()
# recruitment_url_update.crawl_recruitment_update()
# scholarloan_notice_url_update.crawl_scholarloan_notice_update()

Merge_URL.merge_urls()

school_crawling_update.school_crawling_update()

html_img_to_text.to_text()

combined_text.combine_text()