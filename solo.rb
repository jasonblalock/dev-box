root = File.absolute_path(File.dirname(__FILE__))

file_cache_path root
cookbook_path [ root + '/kitchen/cookbooks', root + '/kitchen/site-cookbooks' ]
role_path root + '/roles'
