working_directory "/home/herman/apps/powerdns/current"
pid "/home/herman/apps/powerdns/current/tmp/pids/unicorn.pid"
stderr_path "/home/herman/apps/powerdns/shared/log/unicorn.log"
stdout_path "/home/herman/apps/powerdns/shared/log/unicorn.log"

listen "/tmp/unicorn.powerdns.sock"
worker_processes 2
timeout 30

GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly=true
