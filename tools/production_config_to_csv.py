#!/usr/bin/env python
# Copyright (c) 2015 Yandex LLC. All rights reserved.
# Author: Kirill Kosarev <kirr@yandex-team.ru>

import argparse
from collections import OrderedDict
from collections import namedtuple
from distutils.version import LooseVersion
import json
import logging
import os
import shutil
import sys
import tempfile
import urllib
import urllib2
import xml.etree.ElementTree as ET

PROTO_FILE_URL = ('https://storage.ape.yandex.net/get/browser/'
                  'experiments/browser.proto')
REPO_URL = ('https://bitbucket.browser.yandex-team.ru/projects'
            '/STARDUST/repos/browser-uploads/browse/')
VARIATIONS_SEED = REPO_URL + 'Experiments/variations_seed_pb2.py?raw'
STUDY_PB2 = REPO_URL + 'Experiments/study_pb2.py?raw'
FIELD_TRIALS_XML = os.path.join(os.path.dirname(__file__), '..', 'metrics',
                                'histograms', 'field_trials.xml')
ALL_SUPPORTED_PLATFORMS = ['linux', 'mac', 'win']

# Initialized after loading STUDY_P2 module.
PLATFORM_TYPES = None
CHANNEL_BETA = None
CHANNEL_STABLE = None

#Experiment = namedtuple('Experiment',
                        #['name', 'values', 'is_switch', 'is_obsolete', 'owner'])
XMLDesc = namedtuple('XMLDesc', ['name', 'owner', 'description', 'obsolete'])
CSVDesc = namedtuple('XMLDesc', ['name', 'owner', 'description', 'weight', 'value_str', 'obsolete'])

def _parse_variations(path, base_dir):
    if path:
        with open(path) as f:
            proto_data = f.read()
    else:
        proto_data = urllib2.urlopen(PROTO_FILE_URL).read()
    urllib.urlretrieve(VARIATIONS_SEED,
                       os.path.join(base_dir, 'variations_seed_pb2.py'))
    urllib.urlretrieve(STUDY_PB2, os.path.join(base_dir, 'study_pb2.py'))
    sys.path.append(base_dir)

    from variations_seed_pb2 import VariationsSeed
    variations_seed = VariationsSeed()
    variations_seed.ParseFromString(proto_data)

    from study_pb2 import Study
    global PLATFORM_TYPES
    global CHANNEL_BETA
    global CHANNEL_STABLE
    PLATFORM_TYPES = {
        Study.PLATFORM_MAC: 'mac',
        Study.PLATFORM_WINDOWS: 'win',
        Study.PLATFORM_LINUX: 'linux',
    }
    CHANNEL_BETA = Study.BETA
    CHANNEL_STABLE = Study.STABLE
    return variations_seed


def _get_platforms(filter_platforms):
    if not filter_platforms:
        return ALL_SUPPORTED_PLATFORMS
    platforms = [PLATFORM_TYPES.get(v) for v in filter_platforms]
    return [p for p in platforms if p is not None]


def _get_most_relevant_experiment(study):
    exp = max(study.experiment, key=lambda e: int(e.probability_weight))
    weights_sum = sum(e.probability_weight for e in study.experiment)
    weight = float(exp.probability_weight) / weights_sum
    res = {'name': exp.name}
    if exp.feature_association:
        enabled_features = exp.feature_association.enable_feature
        disabled_features = exp.feature_association.disable_feature
        if enabled_features:
            res['enable_features'] = list(enabled_features)
        if disabled_features:
            res['disabled_features'] = list(disabled_features)
        if exp.param:
            res['params'] = dict((v.name, v.value) for v in exp.param)
    return res, weight


def _should_skip(study, chrome_version, yandex_version):
    filters = study.filter
    if filters.channel and not CHANNEL_STABLE in filters.channel:
        return True

    if chrome_version:
        if (filters.min_version and
                chrome_version < LooseVersion(filters.min_version)):
            logging.info('%s filtered by min version', study.name)
            return True
        if (filters.max_version and
                chrome_version > LooseVersion(filters.max_version)):
            logging.info('%s filtered by max version', study.name)
            return True

    if yandex_version:
        if (filters.ya_min_version and
                yandex_version < LooseVersion(filters.ya_min_version)):
            logging.info('%s filtered by ya_min version', study.name)
            return True
        if (filters.ya_max_version and
                yandex_version > LooseVersion(filters.ya_max_version)):
            logging.info('%s filtered by ya_max version', study.name)
            return True

    if filters.brand_id:
        return True

    if filters.partner_id:
        return True
    return False


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--chromium-version', type=LooseVersion)
    parser.add_argument('--yandex-version', type=LooseVersion)
    parser.add_argument('--verbose', '-v', action='store_true')
    parser.add_argument('--xml-description-file', type=str)
    parser.add_argument('--obsoletes-file', type=str)
    parser.add_argument('-o', '--output-file', type=str)
    parser.add_argument('input_file', nargs='?')
    return parser.parse_args()


def _parse_production_config(args):
    field_trials = {}
    tempdir = tempfile.mkdtemp()
    try:
        variations= _parse_variations(args.input_file, tempdir)
    finally:
        shutil.rmtree(tempdir)

    for study in variations.study:
        if _should_skip(study, args.chromium_version, args.yandex_version):
            continue

        experiment_value, experiment_weight = _get_most_relevant_experiment(study)
        studies_experiments = field_trials.setdefault(study.name, [])
        new_value = {
            'platforms': _get_platforms(study.filter.platform),
            'experiment': experiment_value,
            'experiment_weight': experiment_weight
        }
        if not new_value in studies_experiments:
            studies_experiments.append(new_value)
    return field_trials


def _load_xml(file_path):
    res = {}
    xml_tree = ET.parse(file_path)
    root = xml_tree.getroot()
    for e in root.findall('experiment'):
        values = (
            [group.get('name') for group in e.findall('./groups/group')])
        is_obsolete = True if e.find('./obsolete') is not None else False
        res[e.get('name')] = XMLDesc(e.get('name'),
                                     e.find('./owner').text,
                                     e.find('./description').text,
                                     is_obsolete)
    return res


def _load_obsoletes(file_path):
    with open(file_path) as f:
        res = set([l.strip() for l in f])
    return res


def main():
    args = parse_args()
    if args.verbose:
        logging.basicConfig(level=logging.INFO)

    fieldtrials = _parse_production_config(args)
    xml_desc = _load_xml(args.xml_description_file)
    obsolete_experiments = _load_obsoletes(args.obsoletes_file)

    csv_descriptions = []
    for study_name, values in fieldtrials.iteritems():
        xml_study = xml_desc.get(study_name)
        obsolete_str = 'Possibly removed' if study_name in obsolete_experiments else ' '
        if xml_study:
            description_str = xml_study.description.replace('\n', ' ').replace(';', ' ').strip()
            description_str = ' '.join(description_str.split())
            owner = xml_study.owner
            if xml_study.obsolete:
                obsolete_str = 'Removed'
        else:
            description_str = ' '
            owner = ' '

        value_dict = {}
        for v in values:
            for p in v['platforms']:
                if not p in value_dict:
                    value_dict[p] = (v['experiment']['name'], v['experiment_weight'])
        value_str = ''

        if len(value_dict) == len(ALL_SUPPORTED_PLATFORMS) and len(set(value_dict.values())) == 1:
            value_str = 'all={}'.format(value_dict['win'][0])
            csv_descriptions.append(CSVDesc(
                    study_name, owner, description_str,
                    value_dict['win'][1], value_str, obsolete_str))
        elif len(value_dict):
            for k in sorted(value_dict.keys()):
                value_str = '{}={}'.format(k, value_dict[k][0])
                csv_descriptions.append(CSVDesc(
                        study_name, owner, description_str,
                        value_dict[k][1], value_str, obsolete_str))
        else:
            raise Exception('Study without experiment {}'.format(study_name))

    csv_descriptions = [v for v in csv_descriptions if '=0' not in v.value_str]
    sorted_desc = sorted(csv_descriptions, key=lambda v: v.name)
    with open(args.output_file, 'w') as f:
        for desc in sorted_desc:
            f.write('{};{};{};{};{};{}\n'.format(
                desc.name, desc.owner, desc.description, desc.obsolete,
                int(desc.weight*100), desc.value_str))

    logging.info('All:%s\n Size:%d Switches:%d Not 0:%d Obsoletes:%d',
    str(set([s.name for s in csv_descriptions])),
    len(set([s.name for s in csv_descriptions])),
    len(set([s.name for s in csv_descriptions if s.weight == 1])),
    len(set([s.name for s in csv_descriptions if '0' not in s.value_str])),
    len(set([s.name for s in csv_descriptions if s.obsolete != ' '])))


if __name__ == '__main__':
    main()
