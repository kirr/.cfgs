import datetime
import yin.teamcity.theserver as teamcity
from yin.teamcity.server import TeamcityServer

teamcity_client = teamcity.teamcity_desktop_server()
locator = TeamcityServer.build_locator(build_type_id='Browser_Tests_Perf_Bisect_Bisect',
                                       tags=['perf_autobisect'],
                                       since_date='20170601T102345+0300',
                                       count=1000)
builds = teamcity_client.builds(locator, extra_fields=['queuedDate'])
now = datetime.datetime.utcnow()
builds_in_weeks = [0]*10
success_builds_in_weeks = [0]*10
for b in builds:
    try:
        week_num = (now - b.queued_date).days/7
        if week_num < len(builds_in_weeks):
            builds_in_weeks[week_num] += 1
            if b.status == 'SUCCESS':
                success_builds_in_weeks[week_num] += 1
    except:
        print 'No queued_date for ', b.id, b
print builds_in_weeks
print [float(success_builds_in_weeks[i])/max(builds_in_weeks[i], 1) for i in range(0, 10)]
