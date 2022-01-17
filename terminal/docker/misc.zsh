alias jenkins='docker run --rm -p 8080:8080 -p 50000:50000 -v $(pwd):/var/jenkins_home jenkins/jenkins'
alias nexus='docker run --rm -p 8081:8081 -v $(pwd):/nexus-data sonatype/docker-nexus3'
alias artifactoryoss='docker run --rm -v $(pwd)/data:/var/opt/jfrog/artifactory/data -v $(pwd)/logs:/var/opt/jfrog/artifactory/logs -v $(pwd)/etc:/var/opt/jfrog/artifactory/etc -p 8081:8081 docker.bintray.io/jfrog/artifactory-oss:latest'
alias artifactoryregistry='docker run --rm -v $(pwd)/data:/var/opt/jfrog/artifactory/data -v $(pwd)/logs:/var/opt/jfrog/artifactory/logs -v $(pwd)/etc:/var/opt/jfrog/artifactory/etc -p 80:80 -p 8081:8081 docker.bintray.io/jfrog/artifactory-registry:latest'
alias elasticsearch='docker run --rm --name elasticsearch -p 9200:9200 -p 9300:9300 elasticsearch'
alias zookeeper='docker run --name some-zookeeper --restart always -d -p 2181:2181 -p 2888:2888 -p 3888:3888 zookeeper'
alias ihaskell='docker run --rm -v $(pwd):/notebooks -p 8888:8888 gibiansky/ihaskell'
alias igroovy='docker run --rm -v $(pwd):/home/jovyan/work -p 8888:8888 rahulsom/igroovy'
alias ijulia='docker run --rm -p 8888:8888 -v $PWD:/data auchida/ijulia'
alias sonarqube='docker run --rm -p 9000:9000 -p 9092:9092 sonarqube'
alias smtpstart='docker run --rm -p 25:25 --name smtpserver -d namshi/smtp'
alias smtpstop='docker kill smtpserver'

function letsencrypt() {
  docker run -it --rm \
    -v "$(pwd):/etc/letsencrypt" \
    -p 80:80 -p 443:443 \
    xataz/letsencrypt "$@"
}
