# To use this rudimentary deployment script, you need to:
# - have aws-cli installed
# - have created the target bucket on S3
# - have created the IAM policy and user for full bucket access
# - have this profile referenced in your ~/.aws/credentials file
# - have retrieved your Cloudflare API key and email and stored them in files
# - have retrieved your Cloudflare resource id for the site to deploy

# FILES & FOLDERS TO UPLOAD
files="index.html favicon.png social.png"
folders="css img js vendor"

# AWS SETTINGS
aws_target_bucket="cryptorun.brussels"
aws_profile="cryptorun"

# CLOUDFLARE SETTINGS
cloudflare_resource_id="33fe4b817e1379f706da7480302fe99a"
cloudflare_email_file=".cloudflare-email"
cloudflare_api_file=".cloudflare-api"
cloudflare_email=$(cat "$cloudflare_email_file")
cloudflare_api_key=$(cat "$cloudflare_api_file")

# BUILT ALL FILES
gulp default

# UPLOAD ALL FILES TO S3
for file in $files
do
  aws s3 cp $file s3://$aws_target_bucket/$file --profile $aws_profile --acl public-read
done

# UPLOAD ALL FOLDERS TO S3 (note the recursive upload flag)
for folder in $folders
do
  aws s3 cp $folder/ s3://$aws_target_bucket/$folder --recursive --profile $aws_profile --acl public-read
done

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
