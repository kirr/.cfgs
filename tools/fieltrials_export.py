# Copyright (c) 2017 Yandex LLC. All rights reserved.
# Author: Kirill Kosarev <kirr@yandex-team.ru>

from collections import namedtuple
import json
import os
import xml.etree.ElementTree as ET

ALL_PLATFORMS = set(['linux', 'mac', 'win'])
XMLDesc = namedtuple('XMLDesc', ['name', 'owner', 'description'])

def _load_xml(file_path):
    res = {}
    xml_tree = ET.parse(file_path)
    root = xml_tree.getroot()
    for e in root.findall('experiment'):
        values = (
            [group.get('name') for group in e.findall('./groups/group')])
        is_switch = (True if e.find('./yasen_enabled').text == 'false'
                     else False)
        is_obsolete = True if e.find('./obsolete') is not None else False
        res[e.get('name')] = XMLDesc(e.get('name'),
                                     e.find('./owner').text,
                                     e.find('./description').text)
    return res

def _load_managers():
    res = {}
    with open('/Users/kirr/Downloads/yasenexp.xls - Sheet1.csv') as f:
        lines = f.readlines()

    for l in lines:
        desc = l.split(',')
        owner = desc[2].split('(')[-1][:-1]
        res[desc[0]] = owner
    return res

src_dir = '/Users/kirr/yandex/BROWSER-60228/src'
#config_path = os.path.join(src_dir, 'testing', 'variations',
                           #'fieldtrial_testing_config_yandex.json')
config_path = '/tmp/fieldtrial_testing_config_yandex.json'
xml_path = os.path.join(src_dir, 'tools', 'metrics', 'histograms',
                        'field_trials.xml')

xml_desc = _load_xml(xml_path)
with open(config_path) as f:
    json_config = json.load(f)
managers = _load_managers()

unknown_studies = set()

for study_name, values in json_config.iteritems():
    xml_study = xml_desc.get(study_name)
    if xml_study:
        description_str = xml_study.description.replace('\n', ' ').strip()
        description_str = ' '.join(description_str.split())
        owner = xml_study.owner
    else:
        description_str = 'Missing in field_trials.xml!'
        owner = 'unknown'
    manager_owner = managers.get(study_name, 'unknown')
    value_dict = {}
    for v in values:
        for p in v['platforms']:
            if not p in value_dict:
                value_dict[p] = v['experiments'][0]['name']
    value_str = ''
    if len(value_dict) == 3 and len(set(value_dict.values())) == 1:
        value_str = 'all=' + value_dict['win']
    elif len(value_dict):
        for k in sorted(value_dict.keys()):
            value_str += k + '=' + value_dict[k] + ' '
    else:
        value_str = ' '
    print '{};{};{};{};{}\n'.format(study_name, manager_owner,
                                    owner, description_str, value_str)

    if owner == 'unknown' and manager_owner == 'unknown':
        unknown_studies.add(study_name)

print len(unknown_studies), sorted(unknown_studies)

