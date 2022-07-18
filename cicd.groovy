node('linux') 
{
        stage('Build') {
                build job: 'Port-Pipeline', parameters: [string(name: 'REPO', value: 'bisonport'), string(name: 'DESCRIPTION', 'bisonport' )]
        }
}
