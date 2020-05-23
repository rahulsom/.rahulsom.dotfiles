# Useful containers
cadvisor() {
  docker run -d \
    --restart always \
    -v /:/rootfs:ro \
    -v /var/run:/var/run:rw \
    -v /sys:/sys:ro \
    -v /var/lib/docker/:/var/lib/docker:ro \
    -p 1234:8080 \
    --name cadvisor \
    google/cadvisor

  open http://localhost:1234/
}
alias watchtower='docker run -d --restart always --name watchtower -v /var/run/docker.sock:/var/run/docker.sock centurylink/watchtower'

speedtest() {
  docker run --rm pschmitt/speedtest
}
