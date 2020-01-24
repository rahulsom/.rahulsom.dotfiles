alias ubuntu='docker run --rm -it --hostname ubuntu -v $(pwd):/local -w /local ubuntu bash'
alias centos='docker run --rm -it --hostname centos -v $(pwd):/local -w /local centos bash'
alias openjdk='docker run --rm -it --hostname openjdk -v $(pwd):/local -w /local openjdk:8-alpine sh'
alias alpine='docker run --rm -it --hostname alpine -v $(pwd):/local -w /local alpine sh'
