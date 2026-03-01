pipeline {
    agent any

    environment {
        // Ensuring Python doesn't buffer output which is helpful for Jenkins logs
        PYTHONUNBUFFERED = '1'
    }

    stages {
        stage('Checkout') {
            steps {
                // Jenkins automatically checks out the repository here
                checkout scm
            }
        }

        stage('Setup Environment') {
            steps {
                sh '''
                    # Optional: Print versions for debugging
                    python3 --version
                    pip3 --version

                    # Create a virtual environment
                    python3 -m venv venv
                    
                    # Install Python dependencies (Robot Framework & Browser Library)
                    ./venv/bin/pip install -r requirements.txt
                    
                    # Initialize the Browser library (downloads Playwright Node binaries & Browsers)
                    ./venv/bin/rfbrowser init
                '''
            }
        }

        stage('Run Robot Tests') {
            steps {
                // If tests fail, Jenkins will mark the build as failed or unstable
                sh '''
                    # Run all tests using the virtual environment
                    ./venv/bin/robot --outputdir results .
                '''
            }
            post {
                always {
                    // Archive the Robot Framework reports so you can view them in Jenkins UI
                    archiveArtifacts artifacts: 'results/*.html, results/*.xml', allowEmptyArchive: true
                    
                    // Publish Robot Framework results (Requires the Jenkins Robot Framework Plugin)
                    // If you don't have the plugin installed, you can comment the next line out.
                    robot outputPath: 'results', passThreshold: 100, unstableThreshold: 80
                }
            }
        }
    }
}
