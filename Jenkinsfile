pipeline{
  agent {
    docker{
      image 'ruby:2.3'
      args '-v /var/run/docker.sock:/var/run/docker.sock --group-add=982' 
    }
  }
  options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    disableConcurrentBuilds()
    timeout(time: 1, unit: 'HOURS')
  }

  triggers {
    pollSCM('H 4/* 0 0 1-5')
  }

  stages{
    stage('Init') {
      steps{
        sh 'bundle install'
      }
    }
    stage('Test') {
      steps{
       sh 'rake test'
      }
    }
    stage('Build') {
      steps{
       sh 'rake build'
      }
    }
    /*
    stage('Publish') {
      when {
        branch 'master'
      }
      steps{
       sh 'rake publish'
      }
    }
    */
  }
  /*
  #post {
  #  always {
  #    sh 'rake clean'
  #  }
  #}
  */
}
