# To use this rudimentary deployment script, you need to:
# - have aws-cli installed
# - have created the target bucket on S3
# - have created the IAM policy and user for full bucket access
# - have this profile referenced in your ~/.aws/credentials file
# - have retrieved your Cloudflare API key and email and stored them in files
# - have retrieved your Cloudflare resource id for the site to deploy

# AWS SETTINGS
aws_target_bucket="cryptorun.brussels"
aws_profile="cryptorun"

# CLOUDFLARE SETTINGS
cloudflare_resource_id="20eb2085910d16b077e7c6d525c569c6"
cloudflare_email_file=".cloudflare-email"
cloudflare_api_file=".cloudflare-api"
cloudflare_email=$(cat "$cloudflare_email_file")
cloudflare_api_key=$(cat "$cloudflare_api_file")

# BUILD ALL FILES
npm run build

# UPLOAD ALL BUILT SITE FILES TO S3
aws s3 cp dist/ s3://$aws_target_bucket/dist --recursive --profile $aws_profile --acl public-read
aws s3 cp index.html s3://$aws_target_bucket/index.html --profile $aws_profile --acl public-read
aws s3 cp favicon.png s3://$aws_target_bucket/favicon.png --profile $aws_profile --acl public-read
aws s3 cp social.png s3://$aws_target_bucket/social.png --profile $aws_profile --acl public-read
aws s3 cp src/assets/thumbnails/ s3://$aws_target_bucket/assets --recursive --profile $aws_profile --acl public-read

# PURGE EVERYTHING ON CLOUDFLARE CDN TO RELOAD NEW FILES VERSIONS
curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$cloudflare_resource_id/purge_cache" \
     -H "X-Auth-Email: $cloudflare_email" \
     -H "X-Auth-Key: $cloudflare_api_key" \
     -H "Content-Type: application/json" \
     --data '{"purge_everything":true}' | json_pp

# Command to get the zone id of the website to purge
# curl -X GET "https://api.cloudflare.com/client/v4/zones" \
#    -H "X-Auth-Email: $cloudflare_email" \
#    -H "X-Auth-Key: $cloudflare_api_key" \
#    -H "Content-Type: application/json"
