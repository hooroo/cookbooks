total_memory = `cat /proc/meminfo`.scan(/^MemTotal:\s+(\d+)\skB$/).flatten.first.to_i * 1024
page_size = `getconf PAGESIZE`.to_i
total_memory_pages = (total_memory / page_size).to_i

default['shm']['max'] = total_memory
default['shm']['all'] = total_memory_pages

