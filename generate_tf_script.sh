#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# WARNING: before running this script, make sure you have the correct
# workspace configured as well as your AWS profile with valid creds.
# this script will render the script needed to safely import
# security groups rules into their own standalone resources.

if [ $# -ne 2 ]; then
    echo "Usage: $0 <vars filename> <security group resource name>"
    exit 1
fi

if ! [ -s "${1}" ]; then
    echo "ERROR: var file ${1} is empty."
    exit 1
fi

var_file="${1}"
sg_name="${2}"

# get the current state as json
current_state=$(terraform show -json)

# get the plan as json
tfplan_out=$(mktemp)
terraform plan -var-file="${var_file}" -out="${tfplan_out}"
planned_state=$(terraform show -json "${tfplan_out}")
rm "${tfplan_out}"

# create script
script_name="migrate.sh"
cat << EOF > "${script_name}"
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
EOF

# cache the security groups that have inline rules
sg_filter=$(mktemp)
cat << EOF > "${sg_filter}"
.. | select((type == "object") and (.type == "aws_security_group") and (.name == "${sg_name}"))
EOF
security_groups=$(jq -r -f "${sg_filter}" <<< "${current_state}")
rm "${sg_filter}"

{
    echo
    echo '# 1. remove the security groups from state'
    echo
    jq -r '@sh "terraform state rm \(.address)"' <<< "${security_groups}"

    echo
    echo '# 2. import the individual rules to the state'
    echo
    tempfilter=$(mktemp)
    cat << EOF > "${tempfilter}"
.resource_changes[] | select((.type == "aws_security_group_rule") and (.change.actions[] == "create")) | {address} + .change.after | {address} + {id: [.security_group_id, .type, .protocol, (.from_port|tostring), (.to_port|tostring), .cidr_blocks // .ipv6_cidr_blocks // .source_security_group_id // .prefix_list_ids] | flatten | join("_")} | @sh "terraform import -var-file=${var_file} \(.address) " + .id
EOF
    jq -r -f "${tempfilter}" <<< "${planned_state}"
    rm "${tempfilter}"

    echo
    echo '# 3. import the security groups back to the state again'
    echo
    tempfilter=$(mktemp)
    cat << EOF > "${tempfilter}"
@sh "terraform import -var-file=${var_file} \(.address) " + .values.id
EOF
    jq -r -f "${tempfilter}" <<< "${security_groups}"
    rm "${tempfilter}"
} >> "${script_name}"
