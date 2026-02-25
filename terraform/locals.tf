locals {
  education_users = [
    for user in aws_iam_user.users :
    user.name
    if user.tags.Department == "Education"
  ]

  manager_users = [
    for user in aws_iam_user.users :
    user.name
    if contains(keys(user.tags), "JobTitle")
    && can(regex("(?i)manager|ceo", user.tags.JobTitle))
  ]

  engineer_users = [
    for user in aws_iam_user.users :
    user.name
    if user.tags.Department == "Engineering"
  ]
}