#!/bin/bash
echo "Given Proxy configuration proxy_ip : ${proxy_ip} , proxy_port : ${proxy_port}"
echo "Creating redsocks configuration file using proxy ${proxy_ip}:${proxy_port}..."
sed -e "s|\${proxy_ip}|${proxy_ip}|" \
    -e "s|\${proxy_port}|${proxy_port}|" \
    /etc/redsocks.tmpl > /tmp/redsocks.conf

echo "Generated configuration:"
cat /tmp/redsocks.conf

echo "Activating iptables rules..."
/usr/local/bin/redsocks-fw.sh start

pid=0

# SIGUSR1 handler
usr_handler() {
  echo "usr_handler"
}

# SIGTERM-handler
term_handler() {
    if [ $pid -ne 0 ]; then
        echo "Term signal catched. Shutdown redsocks and disable iptables rules..."
        kill -SIGTERM "$pid"
        wait "$pid"
        /usr/local/bin/redsocks-fw.sh stop
    fi
    exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
trap 'kill ${!}; usr_handler' SIGUSR1
trap 'kill ${!}; term_handler' SIGTERM

echo "Starting redsocks..."
/usr/sbin/redsocks -c /tmp/redsocks.conf &
pid="$!"

# wait indefinetely
while true
do
    tail -f /dev/null & wait ${!}
done