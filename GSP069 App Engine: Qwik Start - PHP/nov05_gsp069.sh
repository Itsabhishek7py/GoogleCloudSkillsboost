## Created by nov05, 2026-0513
git clone https://github.com/GoogleCloudPlatform/php-docs-samples.git
cd php-docs-samples/appengine/standard/helloworld
sed -i 's/^runtime: php.*/runtime: php83/' app.yaml
grep runtime app.yaml
gcloud app deploy --quiet
gcloud app browse
