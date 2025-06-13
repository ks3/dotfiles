#!/usr/bin/env bash
###################################################################################################
# aws.sh
#
# Helper functions for working with AWS.
#
# This script makes use of the following non-standard options in .aws/config.
#
# - account
#   The AWS account ID, only used when not using SSO
#
# - login_url
#   A URL to get an access key and secret when not using SSO
#
# The following utilities are required.
#
# - awscli v2
# - session-manager-plugin
# - aws-ssm-tools (python package)
#


export AWS_PAGER='less -FRX'


#############################
# awsProfile
# Set the active AWS profile
awsProfile() {
    if [[ -z $1 ]]; then
        if [[ -n $AWS_PROFILE ]]; then
            echo "Current profile is $AWS_PROFILE"
        else
            echo "No profile is currently set"
        fi
    elif [[ $1 == unset ]]; then
        unset AWS_PROFILE
    else
        export AWS_PROFILE="$1"
    fi
}
_awsProfile() {
    local cur prev words cword
    _init_completion || return
    if [[ $cword -eq 1 ]]; then
        COMPREPLY=($(compgen -W "$(awsProfiles)" -- "$cur"))
        return 0
    fi
}
complete -F _awsProfile awsProfile

#############################
# awsLogin
# Login to the active profile
awsLogin() {
    if aws configure get sso_session &>/dev/null; then
        aws sso login
    elif aws configure get login_url &>/dev/null; then
        open "$(aws configure get login_url)"
        read -r -N 1 -p "Press any key once credentials are in clipboard"
        [[ $REPLY == $'\n' ]] || echo
        awsSetCredentials
    else
        echo "Not sure how to login to ${AWS_PROFILE}" >&2
        return 1
    fi
}

awsProfiles() {
    aws configure list-profiles | sort
}

awsProfileForAccount() {
    local account="$1"
    if [ -z "$account" ]; then
        echo "Usage: awsGetProfileForAccount <account_id>" >&2
        return 1
    fi

    while read -r line; do

        # remove leading whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        # remove trailing comments
        line="${line%%#*}"
        # remove trailing whitespace
        line="${line%"${line##[![:space:]]*}"}"

        if [[ "$line" == "[profile "* ]]; then
            profile="${line#*profile }"
            profile="${profile%]*}"
        elif [[ "$line" =~ =\ *$account$ ]]; then
            echo "$profile"
        fi

    done < <(grep -v '^ *#' ~/.aws/config)
}

awsCfnBucket() {
    local bucket="$(aws ssm get-parameter --name /Infra/Shared/CfnBucket 2>/dev/null | jq -r .Parameter.Value)"
    if [[ $? -ne 0 || -z "$bucket" ]]; then
        echo "Failed to get /Infra/Shared/CfnBucket from Systems Manager!" >&2
        return 1
    else
        echo "$bucket"
        return 0
    fi
}

awsCfnStacks() {
    local fields="StackName"
    if [[ -n "$*" ]]; then
        for field in "$@"; do
            fields="${fields}${fields:+,}${field}"
        done
    fi
    aws cloudformation list-stacks | jq -r ".StackSummaries | [ .[] | {$fields} ]"
}

awsCfnSync() {
    local bucket="$(awsCfnBucket)"
    local url="https://${bucket}.s3.$(awsCurrentRegion).amazonaws.com"
    if [[ -z $bucket ]]; then
        return 1
    fi
    if aws s3 sync "$@" --exclude '.git*' ./ "s3://${bucket}/"; then
        if hash pbcopy &>/dev/null; then
            [[ -e Root.cfn.yml ]] && url="${url}/Root.cfn.yml"
        fi
        echo "$url" | pbcopy
    fi
}

awsCfnChangeSet() {
    local bucket="$(awsCfnBucket)"
    if [[ -z $bucket ]]; then
        return 1
    fi

    local stack="root"
    if [[ -n $1 ]]; then
        stack="$1"
    fi

    local template="Root.cfn.yml"
    if [[ ! -e $template ]]; then
        [[ -e Root.Testing.cfn.yml ]] && template="Root.Testing.cfn.yml"
    fi
    if [[ -n "$2" ]]; then
        template="$2"
    fi

    local template_url="https://${bucket}.s3.$(awsCurrentRegion).amazonaws.com/${template}"

    echo awsCfnCreateChangeSet "$stack" "$template_url"
    local id="$(awsCfnCreateChangeSet "$stack" "$template_url")"
    if [[ -z $id ]]; then
        echo "Unable to get created change set ID" >&2
        return 1
    fi

    while : ; do
        local status="$(awsCfnChangeSetStatus "$id")"
        echo "$status"

        if [[ "$status" == "CREATE_COMPLETE" ]]; then
            awsCfnChangeSetChangesRecursive "$id"
            read -r -p "(e)xecute, (d)elete, or (q)uit? "
            if [[ "$REPLY" == "e" ]]; then
                aws cloudformation execute-change-set --change-set-name "$id"
                while : ; do
                    local exec_status="$(awsCfnChangeSetExecutionStatus "$id")"
                    echo "$exec_status"
                    if [[ "$exec_status" == "EXECUTE_COMPLETE" ]]; then
                        break;
                    elif [[ "$exec_status" == "EXECUTE_FAILED" ]]; then
                        break;
                    elif [[ "$exec_status" == "OBSOLETE" ]]; then
                        break;
                    fi
                    sleep 5
                done
            elif [[ "$REPLY" == "d" ]]; then
                aws cloudformation delete-change-set --change-set-name "$id"
            elif [[ "$REPLY" == "q" ]]; then
                true
            else
                echo "Invalid selection, quit" >&2
            fi
            break
        fi

        if [[ "$status" == "CREATE_COMPLETE" || "$status" == "FAILED" ]]; then
            break
        fi

        sleep 5
    done
}

awsCreateCodeDeployPackage() {
    if [[ ! -e appspec.yml ]]; then
        echo "No appspec.yml found. Are you in the right directory?" >&2
        return 1
    fi
    local zip_file="../${PWD##*/}.zip"
    [[ -e $zip_file ]] && rm -f "$zip_file"
    zip -x ".git*" -r "../${PWD##*/}.zip" .
}

awsGetTaskCatReport() {
    local tmpdir="$(mktemp -d)"
    pushd "$tmpdir" >/dev/null || return 1

    local s3_path="ritc-qa-artifacts/taskcat_reports"
    local latest_zip="$(aws s3 ls "s3://${s3_path}/" | grep '\.zip$' | sort | awk 'END {print $NF}')"
    aws s3 cp --quiet "s3://${s3_path}/${latest_zip}" .
    report="$(unzip -l "$latest_zip" | awk '/cfnlogs/ {print $NF}')"
    unzip "$latest_zip" "$report"
    cat "$report"

    popd >/dev/null && rm -rf "$tmpdir"
}

awsCfnCreateChangeSet() {
    local stack="$1"
    local template="$2"

    if [[ -z $stack || -z $template ]]; then
        echo "Usage: awsCfnCreateChangeSet <stack> <template>" >&2
        return 1
    fi

    local name="${stack}-$(date +%s)"

    local id="$(aws cloudformation create-change-set \
        --stack-name "$stack" \
        --change-set-name "$name" \
        --template-url "$template" \
        --parameters "ParameterKey=CfBucketName,UsePreviousValue=true" \
        --include-nested-stacks \
        --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND | jq -r .Id)"

    if [[ -n $id ]]; then
        echo "$id"
        return 0
    else
        return 1
    fi
}

awsCfnChangeSetStatus() {
    aws cloudformation describe-change-set --change-set-name "$1" | jq -r .Status
}

awsCfnChangeSetExecutionStatus() {
    aws cloudformation describe-change-set --change-set-name "$1" | jq -r .ExecutionStatus
}

awsCfnChangeSetChanges() {
    aws cloudformation describe-change-set --change-set-name "$1" | jq -r .Changes
}

awsCfnChanges() {
    local id="$1"
    
    if [[ -z $id ]]; then
        if hash pbpaste &>/dev/null; then
            id="$(pbpaste)"
        else
            echo "Usage: awsCfnChanges <id>" >&2
            return 1
        fi
    fi

    awsCfnChangeSetChangesRecursive "$id" | jq -C .
}

awsCfnChangeSetChangesRecursive() {
    local id="$1"
    local nested="$2"

    if [[ -z $id ]]; then
        echo "Usage: awsCfnChangeSetChangesRecursive <id>" >&2
        return 1
    fi

    local changes="$(awsCfnChangeSetChanges "$id")"

    if [[ -z $nested ]]; then
        echo "["
    fi

    if [[ -n $changes && $changes != "[]" ]]; then
        [[ -n $nested ]] && echo ","
        echo -n "{\"id\": \"$id\",\"changes:\": $changes}"
    fi

    for id in $(echo "$changes" | jq -r '.[].ResourceChange.ChangeSetId | select(.!=null)'); do
        awsCfnChangeSetChangesRecursive "$id" 1
    done

    if [[ -z $nested ]]; then
        echo "]"
    fi
}

awsCfnDiff() {
    local bucket="$(awsCfnBucket)"

    if [[ -z $bucket ]]; then
        return 1
    fi

    local s3dir="$(mktemp -d)"
    (
        cd "$s3dir" || exit 1
        aws s3 sync --quiet "s3://${bucket}/" ./
    )

    diff -r --exclude ".git*" "$@" "$s3dir" ./ | sed "s|$s3dir|s3://$bucket|g"

    rm -r "$s3dir"
}

awsAccountId() {
    aws sts get-caller-identity | jq -r '.Account'
}

awsIdentity() {
    aws sts get-caller-identity
}

awsAl2Ami() {
    local ssm_path='/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2'
    aws ssm get-parameter --name "$ssm_path" | jq -r '.Parameter.Value'
}
awsCurrentAmi() {
    local ssm_path='/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64'
    aws ssm get-parameter --name "$ssm_path" | jq -r '.Parameter.Value'
}

awsAmisInUse() {
    aws ec2 describe-instances | jq -r  '.Reservations[].Instances[].ImageId' | sort -u
}

awsInstanceMetadata() {
    local instance="$1"
    shift

    if [[ -z "$instance" ]]; then
        echo "Usage: awsEc2Metadata <instance_id> [args]" >&2
        return 1
    fi

    if [[ -z "$*" ]]; then
        aws ec2 describe-instances \
            --instance-id "$instance" \
            --query 'Reservations[].Instances[].MetadataOptions'
    else
        aws ec2 modify-instance-metadata-options \
            --instance-id "$instance" \
            --http-endpoint enabled \
            "$@"
    fi
}

awsIsAmiInUse() {
    local ami="$1"
    if [[ -z "$ami" ]]; then
        echo "Usage: awsIsAmiInuse <ami_id>" >&2
        return 1
    fi
    if awsAmisInUse  | grep -Eq "^$ami\$"; then
        return 0
    else
        return 1
    fi
}

awsEksClusters() {
    aws eks list-clusters | jq -r '.clusters[]'
}

awsEksLogin() {
    local cluster="$1"
    if [[ -z $cluster ]]; then
        echo "Usage: awsEksLogin [cluster]" >&2
        return 1
    fi
    export KUBECONFIG="$HOME/.kube/${cluster}.config"
    aws eks update-kubeconfig --name "$cluster" >/dev/null
}

awsExportStack() {
    local stack="$1"
    if [[ -z "$stack" ]]; then
        echo "Usage: $0 <stack_name>" >&2
        return 1
    fi
    aws cloudformation get-template --stack-name "$stack" | jq -r '.TemplateBody' > "${stack}.template"
    aws cloudformation describe-stacks --stack-name "$stack" | jq -r '.Stacks[].Parameters' > "${stack}.parameters"
}

awsEmptyBucket() {
    local bucket="$1"
    if [[ -z "$bucket" ]]; then
        echo "Usage: awsEmptyBucket <bucket>" >&2
        return 1
    fi
    delete_json="$(aws s3api list-object-versions --bucket "$bucket" | jq -r '{Objects: [.Versions[] | {Key:.Key, VersionId:.VersionId}], Quiet:true}')"
    aws s3api delete-objects --bucket "$bucket" --delete "$delete_json"
}

awsFindAmiFromSnapshot() {
    local snapshot_id="$1"
    local fields="$2"

    if [[ -z "$snapshot_id" ]]; then
        echo "Usage: $0 <snapshot_id>" >&2
        return 1
    fi

    if [[ -z "$fields" ]]; then
        fields=".ImageId"
    fi

    aws ec2 describe-images --owners self | \
        jq -r ".Images[] | select(.BlockDeviceMappings[].Ebs.SnapshotId==\"$snapshot_id\") | $fields"
}

awsEnvironmentCode() {
    aws ssm get-parameter --name /Infra/Metadata/EnvironmentCode | jq -r '.Parameter.Value'
}

awsFrameworkVersion() {
    aws ssm get-parameter --name /Infra/Metadata/FrameworkVersion | jq -r '.Parameter.Value'
}

awsMyAmis() {
    aws ec2 describe-images --owners self | jq -r '.Images[].ImageId'
}

awsMyUnusedAmis() {
    local amis_in_use="$(awsAmisInUse)"
    local my_amis="$(awsMyAmis)"
    for ami in $my_amis; do
        if ! echo "$amis_in_use" | grep -Eq "^$ami\$"; then
            echo "$ami"
        fi
    done
}

awsSnapshotsBefore() {
    local datestamp="$1"
    local fields="$2"

    if [[ -z "$datestamp" ]]; then
        echo "Usage: $0 <datestamp>" >&2
        return 1
    fi

    if [[ -z "$fields" ]]; then
        fields=".SnapshotId"
    fi

    aws ec2 describe-snapshots --owner-ids "$(awsAccountId)" | \
        jq -r "{ \"Snapshots\": [ .Snapshots[] | select(.StartTime < \"${datestamp}\") | [ ${fields} ] ] }"
}

awsDeleteSnapshotsBefore() {
    local datestamp="$1"
    if [ -z "$datestamp" ]; then
        echo "Usage: awsDeleteSnapshotsBefore <datestamp>" >&2
        echo "       DRYRUN=1 awsDeleteSnapshotsBefore <datestamp>" >&2
        return 1
    fi

    local maybe=""
    if [[ -n "$DRYRUN" ]]; then
        maybe="echo"
    fi

    for snap in $(awsSnapshotsBefore "$datestamp" | jq -r '.Snapshots[] | .[0]'); do
    
        local amis="$(awsFindAmiFromSnapshot "$snap")"
        if [[ -n $amis ]]; then
            for ami in $(awsFindAmiFromSnapshot "$snap"); do
                if awsIsAmiInUse "$ami"; then
                    echo "*** Not deleting $snap, still in use by active AMI $ami"
                    continue 2
                else
                    "$maybe" aws ec2 deregister-image --image-id "$ami"
                fi
            done
        fi
    
        "$maybe" aws ec2 delete-snapshot --snapshot-id "$snap"
    done
}

awsCurrentRegion() {
    aws ec2 describe-availability-zones | jq -r '.AvailabilityZones[0].RegionName'
}

awsRdsClusters() {
    local fields="DBClusterIdentifier,Engine,EngineVersion"
    if [[ -n $* ]]; then
        for f in "$@"; do
            fields="${fields},${f}"
        done
    fi
    aws rds describe-db-clusters | jq -r ".DBClusters | [ .[] | { ${fields} }]"
}

awsEcrLogin() {
    local account="$(awsAccountId)"
    local region="$(awsCurrentRegion)"
    aws ecr get-login-password --region "$region" | docker login --username AWS --password-stdin "$account.dkr.ecr.$region.amazonaws.com"
}

awsSecretValue() {
    local secret="$1"
    if [[ -z "$secret" ]]; then
        echo "Usage: awsSecretValue <secret>" >&2
        return 1
    fi
    aws secretsmanager get-secret-value --secret-id "$secret" | jq -r '.SecretString'
}

awsGetBucketEncryption() {
    local bucket="$1"

    if [[ -z "$bucket" ]]; then
        echo "Usage: awsGetBucketEncryption <bucket>" >&2
        return 1
    fi

    aws s3api get-bucket-encryption --bucket "$bucket" | jq -r '.ServerSideEncryptionConfiguration'
}

awsSetBucketEncryption() {
    local bucket="$1"
    local json

    while read -r -t 3 line; do
        [[ -z "$line" ]] && break
        json="${json}${line}"
    done

    if [[ -z "$bucket" || -z "$json" ]]; then
        echo "Usage: awsSetBucketEncryption <bucket>" >&2
        echo "" >&2
        echo "A valid server side encryption configuration must be passed on stdin" >&2
        echo "bucket: $bucket, json: $json" >&2
        return 1
    fi

    aws s3api put-bucket-encryption --bucket "$bucket" --server-side-encryption-configuration "$json"
}

awsDbConnect() {
    local app="$1"
    if [ -z "$app" ]; then
        echo "Usage: awsDbConnect <app>" >&2
        return 1
    fi

    local json="$(awsSecretValue "$(awsEnvironmentCode)-${app}-dbuser-secret")"
    local engine="$(echo "$json" | jq -r .engine)"
    local host="$(echo "$json" | jq -r .host)"
    local port="$(echo "$json" | jq -r .port)"
    local db="$(echo "$json" | jq -r .dbname)"
    local user="$(echo "$json" | jq -r .username)"
    local pass="$(echo "$json" | jq -r .password)"

    if [[ "$engine" == postgres ]]; then
        PGPASSWORD="$pass" psql -h "$host" -p "$port" -d "$db" -U "$user" 
    elif [[ "$engine" == mysql ]]; then
        MYSQL_PWD="$pass" mysql -h "$host" -P "$port" -D "$db" -u "$user" 
    else
        echo "Unhandled database engine: $engine" >&2
        return 2
    fi
}

awsVpcs() {
    aws ec2 describe-vpcs | jq -r '.Vpcs[] | (.Tags[] | select(.Key == "Name") | .Value), "- "+.VpcId, "- "+.CidrBlock'
}

awsSubnets() {
    aws ec2 describe-subnets | jq -r '.Subnets[] | (.Tags[] | select(.Key=="Name") | .Value), "- "+.SubnetId, "- "+.VpcId, "- "+.AvailabilityZone, "- "+.CidrBlock'
}

awsAccountIdForProfile() {
    local profile="$1"
    if [[ -z $profile ]]; then
        if [[ -n $AWS_PROFILE ]]; then
            profile="$AWS_PROFILE"
        else
            echo "Usage: awsAccountidForProfile <profile>" >&2
            echo "" >&2
            echo "If no profile is given, AWS_PROFILE must be set" >&2
            return 1
        fi
    fi

    local var="account"
    if aws configure get sso_session --profile "$profile" &>/dev/null; then
        var="sso_account_id"
    fi
    aws configure get "$var" --profile "$profile"
}

awsGetConsoleUsers() {
    while read -r user; do
        #echo "${user}: "
        aws iam get-login-profile --user-name "$user" 2>/dev/null
    done < <(aws iam list-users | jq -r '.Users[].UserName')
}

awsSetCredentials() {
    if [[ -z $AWS_PROFILE ]]; then
        echo "Usage: awsSetCredentials" >&2
        echo "" >&2
        echo "The AWS_PROFILE environment variable must be set" >&2
        echo "Credentials will be read from the clipboard where possible. If unable" >&2
        echo "to read from the clipboard, they will be read from stdin." >&2
        return 1
    fi

    update-aws-credentials
    if (( $(awsAccountId) != $(awsAccountIdForProfile) )); then
        echo "The given credentials aren't for the expected account!" >&2
    fi
}

ec2Command() {
    local filter="$1"
    local command="$2"
    
    local output_filter="^((Starting|Exiting) session with [Ss]essionId:.*|Cannot perform start session: EOF)$"
    
    if [[ -z $filter || -z $command ]]; then
        echo "Usage: ec2Command  <id-or-filter> <command>" >&2
        return 1
    fi
    
    local line
    local instance
    local output
    while read -r line; do
        if [[ $line == *"$filter"* ]]; then
            instance="${line%% *}"
            echo -e "\033[1m$instance\033[0m"
            while read -r output; do
                [[ -z $output ]] && continue
                [[ $output =~ $output_filter ]] && continue
                echo "$output"
            done < <(ec2-session --quiet --quiet --command "$command" "$instance" </dev/null 2>&1)
            echo
        fi
    done < <(ec2-session -l)
}

awsSyncFromS3() {
    local src="s3://${PWD##*/}/"
    local dst="./"
    aws s3 sync "$@" "$src" "$dst"
}

awsSyncToS3() {
    local src="./"
    local dst="s3://${PWD##*/}/"
    aws s3 sync "$@" "$src" "$dst"
}

awsRdpTunnel() {
    local id="$1"
    local port="$2"
    aws ssm start-session \
        --target "$id" \
        --document-name AWS-StartPortForwardingSession \
        --parameters "localPortNumber=$port,portNumber=3389"
}
