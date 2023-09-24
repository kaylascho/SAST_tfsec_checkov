package policy

# Define a function to check if a resource has tags
checkTags(resource) {
    # Check if the "tags" attribute exists in the resource
    resource.tags
}

default all_policies = false

import input as params

all_policies {
    # Loop for each resource
    checkPoliciesForResource(params.changedResources[_])
}

checkPoliciesForResource(resource) {
    checkTags(resource)
}
