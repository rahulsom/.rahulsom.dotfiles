# Machine Learning
alias parsey='docker run --rm -i brianlow/syntaxnet 2>/dev/null'
alias pserve='docker run -it --rm -p 7777:80 andersrye/parsey-mcparseface-server'
alias rasa='docker run -p 5000:5000 -v $(pwd):/app rasa/rasa_nlu:latest-full start --path /app'
alias tflow='docker run --rm -v $(pwd):/local -it -w /local -e TF_CPP_MIN_LOG_LEVEL=2 gcr.io/tensorflow/tensorflow:latest-devel python'

# Parsing documents
alias tika='docker run --rm -v $(pwd):/local -it rahulsom/tika'
