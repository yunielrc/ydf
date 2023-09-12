# Aliases
alias aws-ec2-spot-prices="aws ec2 describe-spot-price-history --start-time \"\$(date -Idate)\" --product-descriptions 'Linux/UNIX' --query 'sort_by(SpotPriceHistory, &SpotPrice)'"
alias aws-ec2-volumes="aws ec2 describe-volumes --query 'Volumes[*].{State:State,ID:VolumeId,AZ:AvailabilityZone,Size:Size,Created:CreateTime,Instance:Attachments[0].InstanceId}'"
alias aws-ec2-instances="aws ec2 describe-instances --query 'Reservations[].Instances[].{State:State.Name, Type:InstanceType, ID:InstanceId, PublicIp:PublicIpAddress, Name:Tags[?Key==\`Name\`].Value | [0]}'"
alias aws-ec2-instances-full="aws ec2 describe-instances --query 'Reservations[].Instances[].{State:State.Name, Type:InstanceType, ID:InstanceId, Launched:LaunchTime, PublicIp:PublicIpAddress, Name:Tags[?Key==\`Name\`].Value | [0]}'"
alias ec2ls='aws-ec2-instances'
alias ec2lsf='aws-ec2-instances-full'
alias aws-ec2-stop="aws ec2 stop-instances --instance-ids"
alias ec2stop="aws-ec2-stop"
alias aws-ec2-start="aws ec2 start-instances --instance-ids"
alias ec2start="aws-ec2-start"
alias aws-ec2-terminate="aws ec2 terminate-instances --instance-ids"
alias ec2term="aws-ec2-terminate"
