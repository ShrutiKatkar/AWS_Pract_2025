# create 2 new users and add them to 2 group attach policy to the groups 1 has read only access to ec2 and other has admin access to ec2

resource "aws_iam_user" "group1" {
  name = "IAMUser-Read"
  path = "/system/"
 
  tags = {
    tag-key = "Group_Demo_read"
  }
}
resource "aws_iam_user" "group2" {
  name = "IAMUser-Admin"
  path = "/system/"
 
  tags = {
    tag-key = "Group_Demo_write"
  }
}

#creating 2 groups
resource "aws_iam_group" "developers" {
  name = "developers"
  path = "/users/"
}

resource "aws_iam_group" "users" {
  name = "Users"
  path = "/users/"
}

#adding users to groups
resource "aws_iam_user_group_membership" "memebership1" {
  user = aws_iam_user.group1.name

  groups = [
    aws_iam_group.users.name
  ]
}
resource "aws_iam_user_group_membership" "memebership2" {
  user = aws_iam_user.group2.name

  groups = [
    aws_iam_group.developers.name
  ]
}

#attach a admin policy to developer groups using aws managed policy
resource "aws_iam_group_policy" "my_developer_policy" {
  name  = "my_developer_policy"
  policy =  jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "ec2:*",
            "Effect": "Allow",
            "Resource": "*"
        }]
  })
  
  group = aws_iam_group.developers.name
}

#attach a read only policy to users policy via custom policy
resource "aws_iam_group_policy" "my_user_policy" {
  name  = "my_developer_policy"
  group = aws_iam_group.users.name  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      }, 
    ]
  
})
}

