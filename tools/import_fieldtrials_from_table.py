# Copyright (c) 2017 Yandex LLC. All rights reserved.
# Author: Kirill Kosarev <kirr@yandex-team.ru>

import argparse
from collections import namedtuple
from collections import OrderedDict
import json
import sys
import xml.etree.ElementTree as ET


ALL_PLATFORMS = ['linux', 'mac', 'win']
XMLDesc = namedtuple('XMLDesc', ['name', 'obsolete'])
TSVDesc = namedtuple('TSVDesc', ['name', 'owner', 'description', 'removed',
                                 'platforms_by_value', 'done'])

def _parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--outfile', '-o',
                        default='fieldtrial_testing_config_yandex.json')
    parser.add_argument('--export-to-xml', action='store_true', required=False)
    parser.add_argument('tsv_file')
    parser.add_argument('xml_file')
    return parser.parse_args()


def _load_xml(file_path):
    res = {}
    xml_tree = ET.parse(file_path)
    root = xml_tree.getroot()
    for e in root.findall('experiment'):
        is_obsolete = True if e.find('./obsolete') is not None else False
        res[e.get('name')] = XMLDesc(e.get('name'), is_obsolete)
    return res

def _load_tsv(tsv_path):
    with open(tsv_path) as f:
        lines = f.readlines()[1:]

    res = {}
    for l in lines:
        # values_list = l.split(',')
        values_list = l.split('\t')
        study_name, owner, description = values_list[:3]

        removed_str = values_list[3].lower().strip()
        assert removed_str == 'removed' or not removed_str, removed_str
        removed = (removed_str == 'removed')

        done = values_list[6]

        platforms_by_value = {}
        platform_values_str = values_list[5].strip()
        if platform_values_str:
            platform, experiment_value = platform_values_str.split('=')
            if platform == 'all':
                platforms_by_value[experiment_value] = ALL_PLATFORMS
            else:
                platforms_by_value[experiment_value] = [platform]

        if study_name in res:
            res[study_name].platforms_by_value.update(platforms_by_value)
            continue
        res[study_name] = TSVDesc(study_name, owner, description,
                                  removed, platforms_by_value, done)
    return res

def print_xml_description_for_tsv_desc(tsv_desc):
        print '<experiment name="{}">'.format(tsv_desc.name)
        print '  <owner>{}</owner>'.format(tsv_desc.owner)
        print '  <yasen_enabled>false</yasen_enabled>'
        if tsv_desc.removed:
            print '  <obsolete>Removed in {}</obsolete>'.format(tsv_desc.description)
        print '  <description>\n    {}\n  </description>'.format(tsv_desc.description)
        print '  <groups></groups>'
        print '</experiment>'


def main(args):
    tsv_experiments = _load_tsv(args.tsv_file)
    xml_experiments = _load_xml(args.xml_file)

    valid_experiments = []
    invalid_experiments = []
    undone_experiments = []
    fieldtrials = {}
    for study in sorted(tsv_experiments.values(), key=lambda x: x.name):
        if not study.done:
            undone_experiments.append(study)
            continue

        if study.removed:
            continue

        if study.name not in xml_experiments:
            invalid_experiments.append(study.name)
            continue

        fieldtrials[study.name] = []
        for v, platforms in study.platforms_by_value.iteritems():
            new_value = {'platforms': platforms, 'experiments': [{'name': v}]}
            fieldtrials[study.name].append(new_value)
        valid_experiments.append(study.name)

    xml_obsoletes = []
    for study_name, xml_desc in xml_experiments.iteritems():
        if study_name in valid_experiments or study_name in undone_experiments:
            continue
        if xml_desc.obsolete:
            continue
        tsv_desc = tsv_experiments.get(study_name)
        if tsv_desc and tsv_desc.removed:
            xml_obsoletes.append(study_name)
            continue
        fieldtrials[study_name] = []


    sorted_trials = OrderedDict(sorted(fieldtrials.items()))
    with open(args.outfile, 'w') as f:
        json.dump(sorted_trials, f, indent=4, separators=(',', ': '))

    if args.export_to_xml:
        missing_xml = invalid_experiments + xml_obsoletes
        print missing_xml
        for name in sorted(missing_xml):
            tsv_desc = tsv_experiments[name]
            print_xml_description_for_tsv_desc(tsv_desc)

    print 'valid_experiment:{}  count:{}\n'\
          'invalid_experiment:{}  count:{}\n'\
          'undone_experiment:{}  count:{}\n'.format(
        valid_experiments, len(valid_experiments),
        invalid_experiments, len(invalid_experiments),
        undone_experiments, len(undone_experiments))


if __name__ == '__main__':
    args = _parse_args()
    main(args)
