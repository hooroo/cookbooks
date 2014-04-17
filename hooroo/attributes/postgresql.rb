shared_mem_proportion = 0.25
effective_cache_size_proportion = 0.80
total_memory = `cat /proc/meminfo`.scan(/^MemTotal:\s+(\d+)\skB$/).flatten.first.to_i * 1024
page_size = `getconf PAGESIZE`.to_i
total_memory_mb = (total_memory / 1048576).to_i
total_memory_pages = (total_memory / page_size).to_i

shared_buffers = (total_memory_mb * shared_mem_proportion).to_i
sysctl_shared_buffers = total_memory
effective_cache_size = (total_memory_mb * effective_cache_size_proportion).to_i
if total_memory < 5147483648
    maintenance_work_mem = "128MB"
    work_mem = "32MB"
else
    maintenance_work_mem= "256MB"
    work_mem = "64MB"
end

default['postgresql']['config']['max_fsm_pages'] = 500000
default['postgresql']['config']['max_fsm_relations'] = 10000
default['postgresql']['config']['wal_buffers'] = "8MB"
default['postgresql']['config']['wal_writer_delay'] = "200ms"
default['postgresql']['config']['checkpoint_segments'] = 100
default['postgresql']['config']['checkpoint_timeout'] = "5min"
default['postgresql']['config']['max_stack_depth'] = "8MB"
default['postgresql']['config']['max_wal_senders'] = 5
default['postgresql']['config']['wal_keep_segments'] = 128
default['postgresql']['config']['effective_cache_size'] = effective_cache_size
default['postgresql']['config']['default_statistics_target'] = 100
default['postgresql']['config']['shared_buffers'] = shared_buffers
default['postgresql']['config']['work_mem'] = work_mem
default['postgresql']['config']['maintenance_work_mem'] = maintenance_work_mem
default['postgresql']['config']['max_files_per_process'] = 65535
default['postgresql']['config']['shmmax'] = total_memory
default['postgresql']['config']['shmall'] = total_memory_pages

