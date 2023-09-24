package project_policies

#entry point for tags enforcement 
checkTags(resource) {
 # read the tags based on the resource type
 tags = readTags(resource.type, resource)
 # check for the tag enforcement
 ensureMandatoryTags(tags)
}
# every resource to be evaluated will have a 'readTags' function for # itself the returned document should resemble the below structure
# {'tag-name': {value: 'tag-value'}}
readTags("aws_instance", resource) = tags {
 tags = resource.changedAttributes.tags
}

checkTagHasValue(tag) {
 re_match("[^\\s]+", tag.value)
}