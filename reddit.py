{\rtf1\ansi\ansicpg1252\cocoartf2580
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 # libraries \
import pandas as pd\
import datetime as dt\
from psaw import PushshiftAPI\
import os\
\
# set working directory\
os.chdir("/Users/rubenbach/Nextcloud/Lehre/FSS 2020/Reddit/")\
# define API\
api = PushshiftAPI()\
start_epoch_2020 = int(dt.datetime(2020, 3, 20).timestamp())  # set time period\
end_epoch_2020 = int(dt.datetime(2020, 9, 21).timestamp())  # set time period\
searchqueries = [\
    "black lives matter",\
    "white lives matter",\
    "xxxx",\
]  # Put in your search words here\
subreddit_list = ["liberal", "democrats", "xxxx"]  # Put in the desired subreddits here\
submlist = []\
submlistname = []\
all_comments = []\
all_comments_df = []\
for subred in subreddit_list:\
    for searchquery in searchqueries:\
        submlist = list(\
            api.search_submissions(\
                q=searchquery,\
                before=end_epoch_2020,\
                after=start_epoch_2020,\
                subreddit=subred,\
            )\
        )\
        submlistname = searchquery.replace(" ", "")\
        pd.DataFrame([s.d_ for s in submlist]).to_csv(\
            subred + submlistname + "subm_list.csv", index=False\
        )\
        list_submission_ids = [s.id for s in submlist]\
        all_comments = []\
        for submission_id in list_submission_ids:\
            comments_for_submission = list(api.search_comments(link_id=submission_id))\
            all_comments = all_comments + [c.d_ for c in comments_for_submission]\
            all_comments_df = pd.DataFrame(all_comments)\
            all_comments_df.to_csv(\
                subred + submlistname + "all_commments.csv", sep="\\t", encoding="utf-8"\
            )\
}