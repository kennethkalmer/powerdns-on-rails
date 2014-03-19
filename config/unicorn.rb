working_directory "/home/herman/apps/powerdns"
pid "/home/herman/apps/powerdns/tmp/pids/unicorn.pid"
stderr_path "/home/herman/apps/powerdns/log/unicorn.log"
stdout_path "/home/herman/apps/powerdns/log/unicorn.log"

listen "/tmp/unicorn.powerdns.sock"
worker_processes 2
timeout 30

GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly=true