node('linux') 
{
        stage('Build') {
                build job: 'Port-Pipeline', parameters: [string(name: 'REPO', value: 'bisonport'), string(name: 'DESCRIPTION', 'Bison is a general-purpose parser generator that converts an annotated context-free grammar into a deterministic LR or generalized LR (GLR) parser.' )]
        }
}
