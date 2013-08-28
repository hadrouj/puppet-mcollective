class mcollective ($side, $activemqpassword, $pskpassword, $conf_file, $activemq_server) {

   if $side == 'client' {
     package { 'mcollective-client': ensure => '2.2.4-1.el6' }
     #We need to synchronize facts, application and agent directories only for the client (management server)

     #Copy facts directory
     #Todo: Comment vérifier que le repertoire est bien synchronisé avec Git tout en évitant la copie inutile
     file {"copy_mcollective_facts":
          path     => "/usr/libexec/mcollective/mcollective/facts",
          source   => "/etc/puppet/modules/mcollective/files/facts",
          ensure   => directory,
          recurse  => true, # synchronize the contents of the directory recursively
          owner    => 'root',
          group    => 'root',
          mode     => 0775,
          require  => Package['mcollective-client'],
     }

     #Copy application directory
     file {"copy_mcollective_application":
          path     => "/usr/libexec/mcollective/mcollective/application",
          source   => "/etc/puppet/modules/mcollective/files/application",
          ensure   => directory,
          recurse  => true, # synchronize the contents of the directory recursively
          owner    => 'root',
          group    => 'root',
          mode     => 0775,
          require  => Package['mcollective-client'],
     }

     #Copy agent directory
     file {"copy_mcollective_agent":
          path       => "/usr/libexec/mcollective/mcollective/agent",
          source     => "/etc/puppet/modules/mcollective/files/agent",
          ensure     => directory,
          recurse    => true, # synchronize the contents of the directory recursively
          owner      => 'root',
          group      => 'root',
          mode       => 0775,
          require  => Package['mcollective-client'],
     }
     file { "download_mcollective_config":
          path       => "/etc/mcollective/client.cfg",
          content    => template("mcollective/client.cfg.erb"),
          ensure     => file,
          require  => Package['mcollective-client'],
     }
   }
   elsif $side == 'server' {
     package { 'mcollective': ensure => '2.2.4-1.el6' }
     file {"copy_mcollective_facts":
          path     => "/usr/libexec/mcollective/mcollective/facts",
          source   => "puppet:///modules/mcollective/facts",
          ensure   => directory,
          recurse  => true, # synchronize the contents of the directory recursively
          owner    => 'root',
          group    => 'root',
          mode     => 0775,
          require  => Package['mcollective'],
     }

     #Copy application directory
     file {"copy_mcollective_application":
          path     => "/usr/libexec/mcollective/mcollective/application",
          source   => "puppet:///modules/mcollective/application",
          ensure   => directory,
          recurse  => true, # synchronize the contents of the directory recursively
          owner    => 'root',
          group    => 'root',
          mode     => 0775,
          require  => File["copy_mcollective_facts"],
     }

     #Copy agent directory
     file {"copy_mcollective_agent":
          path       => "/usr/libexec/mcollective/mcollective/agent",
          source     => "puppet:///modules/mcollective/agent",
          ensure     => directory,
          recurse    => true, # synchronize the contents of the directory recursively
          owner      => 'root',
          group      => 'root',
          mode       => 0775,
          require    => File["copy_mcollective_application"],
     }
     file {"download_mcollective_config":
          path       => "/etc/mcollective/server.cfg",
          content    => template("mcollective/server.cfg.erb"),
          ensure     => file,
          require    => File["copy_mcollective_agent"],
     }

     #Start the service once the config files are set
     service { 'mcollective':
       enable     => true,
       ensure     => running,
       require    => File["download_mcollective_config"],
     }
   }
}