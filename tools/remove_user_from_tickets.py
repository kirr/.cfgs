# coding=utf-8

import os
import sys

from startrek_client import Startrek

ST_TOKEN = os.getenv('ST_TOKEN')
USER = sys.argv[1]

st_client = Startrek('kirr_users_remover',
                     token=ST_TOKEN,
                     headers={'Accept-Language': 'en-US, en'})

assigned_to_query =  'Assignee: {} AND Status: Open AND (Queue: "Bro Perf" OR Queue: "Наш Браузер")'.format(USER)
assigned_to_query = 'Summary: "Anomalies caused by PR 118247"'
st_client.bulkchange.update(assigned_to_query, assignee="malets", tags={'add': 'from:kirr'})


followers_query = 'Followers: {} AND Status: Open AND (Queue: "Bro Perf" OR Queue: "Наш Браузер")'.format(USER)
followers_change = {"followers": {"remove": [USER]}}
st_client.bulkchange.update(followers_query, followers={"remove": [USER]})
