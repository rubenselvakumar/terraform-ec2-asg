pipeline {
    agent{
        label "aws-deploy-jenkins-slave"
    }
  parameters {
    choice choices: ['dev', 'prod'], description: 'Choose environment to deploy', name: 'ENVIRONMENT' 
    string defaultValue: 'eu-west-1', description: 'AWS REGION', name: 'AWS_REGION', trim: true
    string defaultValue: 'master', description: 'Git branch', name: 'GIT_BRANCH', trim: true
    string defaultValue: '/Workspace/terraform/ec2-asg-webapp', description: 'Terraform Location', name: 'TFM_MAIN_DIR', trim: true
  }
  options {
    skipDefaultCheckout()
    buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '30', daysToKeepStr: '', numToKeepStr: '30')
    timestamps()
    ansiColor('xterm')
    timeout(activity: true,time: 2, unit: 'HOURS')
  }
  environment {
    ENVIRONMENT                     = "${params.ENVIRONMENT}"
    AWS_REGION                      = "${params.AWS_REGION}"
    GIT_BRANCH                      = "${params.GIT_BRANCH}"
    TFM_MAIN_DIR                    = "${params.TFM_MAIN_DIR}"
    TFM_MAIN_STATE_FILE             = "${params.TFM_MAIN_DIR}/${params.ENVIRONMENT}/main.tfstate"
  }
  stages {
    stage('Checkout') {
      steps {
        script {
          checkout changelog: false, poll: false, scm: [
            $class: 'GitSCM',
            branches: [[name: "*/${GIT_BRANCH}"]],
            doGenerateSubmoduleConfigurations: false,
            submoduleCfg: [],
            userRemoteConfigs: [
              [credentialsId: 'gitlab_ssh', url: 'git@gitlab.com:mycompany/myproject/terraform-common.git']
            ]
          ]
          currentBuild.description = "${ENVIRONMENT}"
        }
      }
    }
    stage('Terraform Main Init') {
      steps {
        script {
          withAwsCli(
            credentialsId: "aws-access-${ENVIRONMENT}", 
            defaultRegion: AWS_REGION
          ) {
            sh """              
              echo ${WORKSPACE}/${TFM_MAIN_DIR}
              cd ${WORKSPACE}/${TFM_MAIN_DIR}
              terraform init -no-color -input=false -backend-config key=${TFM_MAIN_STATE_FILE}
            """
          }
        }
      }
    }
    stage('Terraform Main Plan') {
      steps {
        script {
          withAwsCli(
            credentialsId: "aws-access-${ENVIRONMENT}", 
            defaultRegion: AWS_REGION
          ) {
            sh """
              echo ${WORKSPACE}/${TFM_MAIN_DIR}
              cd ${WORKSPACE}/${TFM_MAIN_DIR}
              terraform plan -no-color -input=false -out=create.tfplan
            """
          }
        }
      }
    }
    stage('Approval Main TF') {
      steps {
        input 'Run Terraform Apply For Main?'
      }
    }
    stage('Terraform Main Apply') {
      steps {
        script {
          withAwsCli(
            credentialsId: "aws-access-${ENVIRONMENT}", 
            defaultRegion: AWS_REGION
          ) {
            sh """
              echo ${WORKSPACE}/${TFM_MAIN_DIR}
              cd ${WORKSPACE}/${TFM_MAIN_DIR}
              terraform apply -no-color -input=false create.tfplan
            """
          }
        }
      }
    }
  // end stages
  }
// end pipeline
}
