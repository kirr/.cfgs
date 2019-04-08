import sys
import urllib
import yaml

TEMPLATE_YAML = """
    telemetry_commit: bfa6e7c2ec24932dbd81129e9b025738f5bfef70

    story_set:
      loading_page_set:
        benchmark: serp_loading
        platform: desktop
        timeout: 60
        stories_config:
          stories: []

    benchmarks:
      - name: serp_loading
        os: [android]
        story_set: loading_page_set
        timeout: 60
"""


def generate_story(product, request):
    story_name = request
    if product == 'yandex':
        story_url = 'https://yandex.ru/search/?{}'.format(
            urllib.urlencode({'text': request.encode('utf-8')}))
    elif product == 'google':
        story_url = 'https://google.ru/search?{}'.format(
            urllib.urlencode({'q': request.encode('utf-8')}))
    else:
        raise NotImplementedError()

    return {'name': story_name, 'url': story_url, 'type': 'simple'}


test_config = yaml.load(TEMPLATE_YAML)
requests_file, product, output = sys.argv[1:]

with open(requests_file) as f:
    requests = []
    for x in xrange(300):
        request = next(f)
        text = urllib.unquote_plus(request.rstrip('\n')).decode('utf-8')
        print text
        requests.append(text)

stories = [generate_story(product, x) for x in requests]
test_config['story_set']['loading_page_set']['stories_config']['stories'] = stories
test_config['product'] = product

with open(output, 'w') as f:
    yaml.safe_dump(test_config, f, encoding='utf-8', allow_unicode=True)
