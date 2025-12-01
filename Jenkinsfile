
pipeline {
    agent none // El agente se definirá por cada 'stage'

    stages {
        // --- STAGE 1: Compilar la Lambda de Java con Maven ---
        stage('Build Lambda') {
            agent { label 'maven' } // Usa nuestro agente con Maven

            steps {
                script {
                    dir('modules/inscripcionesLambda/java') {
                        sh 'mvn clean package'
                    }
                    // Guardamos el JAR compilado para el siguiente stage
                    stash(name: 'lambda-jar', includes: 'modules/inscripcionesLambda/java/target/inscripciones.jar')
                }
            }
        }

        // --- STAGE 2: Desplegar la infraestructura con Terraform ---
        stage('Deploy Infra') {
            agent { label 'terraform' } // Usa nuestro agente con Terraform

            steps {
                script {
                    // Recuperamos el JAR del stage anterior
                    unstash('lambda-jar')

                    dir('infra') {
                        sh 'terraform init'
                        // Ejecutamos terraform apply con las variables necesarias
                        sh 'terraform apply -auto-approve \
                            -var="stage=dev" \
                            -var="lambda_function_name=InscripcionesLambda" \
                            -var="lambda_handler=com.academia.ApiHandler::handleRequest" \
                            -var="jar_path=../modules/inscripcionesLambda/java/target/inscripciones.jar" \
                            -var="ddb_table_name=InscripcionesTapp"'
                    }
                }
            }
        }
    }
    post {
        always {
            echo 'Pipeline finalizado. Limpiando workspace...'
            cleanWs()
        }
    }
}
