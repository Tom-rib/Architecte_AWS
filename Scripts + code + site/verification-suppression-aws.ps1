# ========================================
# VERIFICATION COMPLETE AWS
# ========================================

Write-Host "VERIFICATION COMPLETE AWS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. EC2 INSTANCES (running)
Write-Host "[1] EC2 Instances (running)" -ForegroundColor Yellow
$ec2 = aws ec2 describe-instances --region eu-west-3 --query "Reservations[].Instances[?State.Name=='running'].InstanceId" --output text
if ($ec2) { 
    Write-Host "ERREUR: $ec2" -ForegroundColor Red 
} else { 
    Write-Host "OK - VIDE" -ForegroundColor Green 
}
Write-Host ""

# 2. RDS (running)
Write-Host "[2] RDS Instances" -ForegroundColor Yellow
$rds = aws rds describe-db-instances --region eu-west-3 --query "DBInstances[].DBInstanceIdentifier" --output text
if ($rds) { 
    Write-Host "ERREUR: $rds" -ForegroundColor Red 
} else { 
    Write-Host "OK - VIDE" -ForegroundColor Green 
}
Write-Host ""

# 3. LAMBDA
Write-Host "[3] Lambda Functions" -ForegroundColor Yellow
$lambda = aws lambda list-functions --region eu-west-3 --query "Functions[].FunctionName" --output text
if ($lambda) { 
    Write-Host "ERREUR: $lambda" -ForegroundColor Red 
} else { 
    Write-Host "OK - VIDE" -ForegroundColor Green 
}
Write-Host ""

# 4. API GATEWAY
Write-Host "[4] API Gateway" -ForegroundColor Yellow
$api = aws apigateway get-rest-apis --region eu-west-3 --query "items[].name" --output text
if ($api) { 
    Write-Host "ERREUR: $api" -ForegroundColor Red 
} else { 
    Write-Host "OK - VIDE" -ForegroundColor Green 
}
Write-Host ""

# 5. ECS CLUSTERS
Write-Host "[5] ECS Clusters" -ForegroundColor Yellow
$ecs = aws ecs list-clusters --region eu-west-3 --query "clusterArns" --output text
if ($ecs) { 
    Write-Host "ERREUR: $ecs" -ForegroundColor Red 
} else { 
    Write-Host "OK - VIDE" -ForegroundColor Green 
}
Write-Host ""

# 6. ECR REPOSITORIES
Write-Host "[6] ECR Repositories" -ForegroundColor Yellow
$ecr = aws ecr describe-repositories --region eu-west-3 --query "repositories[].repositoryName" --output text
if ($ecr) { 
    Write-Host "ERREUR: $ecr" -ForegroundColor Red 
} else { 
    Write-Host "OK - VIDE" -ForegroundColor Green 
}
Write-Host ""

# 7. S3 BUCKETS
Write-Host "[7] S3 Buckets" -ForegroundColor Yellow
$s3 = aws s3 ls --output text
if ($s3) { 
    Write-Host "ERREUR: $s3" -ForegroundColor Red 
} else { 
    Write-Host "OK - VIDE" -ForegroundColor Green 
}
Write-Host ""

# 8. STEP FUNCTIONS
Write-Host "[8] Step Functions" -ForegroundColor Yellow
$sf = aws stepfunctions list-state-machines --region eu-west-3 --query "stateMachines[].name" --output text
if ($sf) { 
    Write-Host "ERREUR: $sf" -ForegroundColor Red 
} else { 
    Write-Host "OK - VIDE" -ForegroundColor Green 
}
Write-Host ""

# 9. SNS TOPICS
Write-Host "[9] SNS Topics" -ForegroundColor Yellow
$sns = aws sns list-topics --region eu-west-3 --query "Topics[].TopicArn" --output text
if ($sns) { 
    Write-Host "ERREUR: $sns" -ForegroundColor Red 
} else { 
    Write-Host "OK - VIDE" -ForegroundColor Green 
}
Write-Host ""

# 10. AUTO SCALING GROUPS
Write-Host "[10] Auto Scaling Groups" -ForegroundColor Yellow
$asg = aws autoscaling describe-auto-scaling-groups --region eu-west-3 --query "AutoScalingGroups[].AutoScalingGroupName" --output text
if ($asg) { 
    Write-Host "ERREUR: $asg" -ForegroundColor Red 
} else { 
    Write-Host "OK - VIDE" -ForegroundColor Green 
}
Write-Host ""

# 11. LOAD BALANCERS
Write-Host "[11] Load Balancers" -ForegroundColor Yellow
$lb = aws elbv2 describe-load-balancers --region eu-west-3 --query "LoadBalancers[].LoadBalancerArn" --output text
if ($lb) { 
    Write-Host "ERREUR: $lb" -ForegroundColor Red 
} else { 
    Write-Host "OK - VIDE" -ForegroundColor Green 
}
Write-Host ""

# 12. LAUNCH TEMPLATES
Write-Host "[12] Launch Templates" -ForegroundColor Yellow
$lt = aws ec2 describe-launch-templates --region eu-west-3 --query "LaunchTemplates[].LaunchTemplateName" --output text
if ($lt) { 
    Write-Host "ERREUR: $lt" -ForegroundColor Red 
} else { 
    Write-Host "OK - VIDE" -ForegroundColor Green 
}
Write-Host ""

# RESULTAT FINAL
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VERIFICATION TERMINEE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
