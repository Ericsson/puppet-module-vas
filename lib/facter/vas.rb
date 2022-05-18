# vas_usersallow
Facter.add('vas_usersallow') do
  setcode do
    if File.exist?('/etc/opt/quest/vas/users.allow')
      cmd = 'cat /etc/opt/quest/vas/users.allow 2>/dev/null | tr -d "\r" | sed "/^$/d" | egrep -v "^#" | sort | tr -s "\n" " "'
      Facter::Util::Resolution.exec(cmd)
    end
  end
end

# vas_domain
Facter.add('vas_domain') do
  setcode do
    if File.exist?('/opt/quest/bin/vastool')
      cmd = '/opt/quest/bin/vastool info domain 2>/dev/null'
      Facter::Util::Resolution.exec(cmd)
    end
  end
end

# vas_server_type
Facter.add('vas_server_type') do
  setcode do
    if File.exist?('/opt/quest/bin/vastool')
      cmd = '/opt/quest/bin/vastool info servers | egrep "^Servers type" | cut -f4 -d" " | cut -f1 -d","'
      Facter::Util::Resolution.exec(cmd)
    end
  end
end

# vas_servers
Facter.add('vas_servers') do
  setcode do
    if File.exist?('/opt/quest/bin/vastool')
      cmd = '/opt/quest/bin/vastool info servers | egrep -v "^Servers type" | tr [:upper:] [:lower:] | tr -s "\n" " " 2>/dev/null'
      Facter::Util::Resolution.exec(cmd)
    end
  end
end

# vas_site
Facter.add('vas_site') do
  setcode do
    if File.exist?('/opt/quest/bin/vastool')
      cmd = '/opt/quest/bin/vastool info servers | egrep "^Servers type" | cut -f10 -d" " | cut -f1 -d":" 2>/dev/null'
      Facter::Util::Resolution.exec(cmd)
    end
  end
end

# vas_version
Facter.add('vas_version') do
  setcode do
    if File.exist?('/opt/quest/bin/vastool')
      cmd = '/opt/quest/bin/vastool -v | grep "vastool" | cut -f 4 -d " "'
      Facter::Util::Resolution.exec(cmd)
    end
  end
end

# vasmajversion
Facter.add('vasmajversion') do
  setcode do
    if File.exist?('/opt/quest/bin/vastool')
      cmd = '/opt/quest/bin/vastool -v | grep "vastool" | cut -f 4 -d " "| cut -f 1 -d "."'
      Facter::Util::Resolution.exec(cmd)
    end
  end
end
