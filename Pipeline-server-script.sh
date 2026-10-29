pipeline {
    agent any

    stages {
        stage('Server Information') {
            steps {
                echo 'Checking EC2 server information'
                sh '''
                    hostname
                    date
                    uptime
                '''
            }
        }

        stage('CPU and Memory Check') {
            steps {
                echo 'Checking CPU load and memory'
                sh '''
                    uptime
                    free -h
                '''
            }
        }

        stage('Disk Space Check') {
            steps {
                echo 'Checking root filesystem usage'
                sh '''
                    df -h /
                    df -P / | awk 'NR==2 {
                        usage=$5
                        sub(/%/, "", usage)
                        if (usage+0 >= 80) {
                            print "WARNING: Disk usage is " usage "%"
                            exit 1
                        }
                        print "Disk usage is healthy: " usage "%"
                    }'
                '''
            }
        }

        stage('Java Check') {
            steps {
                echo 'Checking Java installation'
                sh 'java -version'
            }
        }

        stage('Jenkins Service Check') {
            steps {
                echo 'Checking Jenkins service'
                sh '''
                    if systemctl is-active --quiet jenkins; then
                        echo "Jenkins service is RUNNING"
                    else
                        echo "Jenkins service is NOT RUNNING"
                        exit 1
                    fi
                '''
            }
        }

        /*
        stage('AWS IAM Role Check') {
            steps {
                echo 'Verifying AWS identity'
                sh '''
                    if command -v aws >/dev/null 2>&1; then
                        aws sts get-caller-identity
                    else
                        echo "AWS CLI is not installed"
                        exit 1
                    fi
                '''
            }
        }
        */
    }

    post {
        success {
            echo 'SUCCESS: All health-check stages passed.'
        }

        failure {
            echo 'FAILURE: A stage failed. Check the console output.'
        }

        always {
            echo 'Health-check pipeline execution completed.'
        }
    }
}
