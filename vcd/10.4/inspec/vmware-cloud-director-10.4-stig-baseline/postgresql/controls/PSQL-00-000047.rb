control 'PSQL-00-000047' do
  title 'PostgreSQL must invalidate session identifiers upon user logout or other session termination.'
  desc  "
    Captured sessions can be reused in \"replay\" attacks. This requirement limits the ability of adversaries to capture and continue to employ previously valid session IDs.

    This requirement focuses on communications protection for PostgreSQL session rather than for the network packet. The intent of this control is to establish grounds for confidence at each end of a communications session in the ongoing identity of the other party and in the validity of the information being transmitted.

    Session IDs are tokens generated by PostgreSQL to uniquely identify a user's (or process's) session. DBMSs will make access decisions and execute logic based on the session ID.

    Unique session IDs help to reduce predictability of said identifiers. Unique session IDs address man-in-the-middle attacks, including session hijacking or insertion of false information into a session. If the attacker is unable to identify or guess the session information related to pending application traffic, they will have more difficulty in hijacking the session or otherwise manipulating valid sessions.

    When a user logs out, or when any other session termination event occurs, PostgreSQL must terminate the user session(s) to minimize the potential for sessions to be hijacked.
  "
  desc  'rationale', ''
  desc  'check', "
    As a database administrator, perform the following at the command prompt:

    $ psql -A -t -c \"SHOW tcp_keepalives_idle\"
    $ psql -A -t -c \"SHOW tcp_keepalives_interval\"
    $ psql -A -t -c \"SHOW tcp_keepalives_count\"
    $ psql -A -t -c \"SHOW statement_timeout\"

    If these settings are not set, this is a finding.
  "
  desc 'fix', "
    As a database administrator, perform the following at the command prompt:

    $ psql -c \"ALTER SYSTEM SET statement_timeout = '10000';\"
    $ psql -c \"ALTER SYSTEM SET tcp_keepalives_idle = '10';\"
    $ psql -c \"ALTER SYSTEM SET tcp_keepalives_interval = '10';\"
    $ psql -c \"ALTER SYSTEM SET tcp_keepalives_count = '10';\"

    Note: Set the following parameters to organizational requirements or use the values in the example above.

    Reload the PostgreSQL service by running the following command:

    # systemctl reload postgresql

    or

    # service postgresql reload
  "
  impact 0.5
  tag severity: 'medium'
  tag gtitle: 'SRG-APP-000220-DB-000149'
  tag satisfies: ['SRG-APP-000295-DB-000305']
  tag gid: nil
  tag rid: nil
  tag stig_id: 'PSQL-00-000047'
  tag cci: ['CCI-001185', 'CCI-002361']
  tag nist: ['SC-23 (1)', 'AC-12']

  sql = postgres_session("#{input('postgres_user')}", "#{input('postgres_pass')}", "#{input('postgres_host')}")

  describe.one do
    describe sql.query('SHOW tcp_keepalives_idle;', ["#{input('postgres_default_db')}"]) do
      its('output') { should cmp '0' }
    end
    describe kernel_parameter('net.ipv4.tcp_keepalive_time') do
      its('value') { should cmp '7200' }
    end
  end

  describe.one do
    describe sql.query('SHOW tcp_keepalives_interval;', ["#{input('postgres_default_db')}"]) do
      its('output') { should cmp '0' }
    end
    describe kernel_parameter('net.ipv4.tcp_keepalive_intvl') do
      its('value') { should cmp '75' }
    end
  end

  describe.one do
    describe sql.query('SHOW tcp_keepalives_count;', ["#{input('postgres_default_db')}"]) do
      its('output') { should cmp '0' }
    end
    describe kernel_parameter('net.ipv4.tcp_keepalive_probes') do
      its('value') { should cmp '9' }
    end
  end

  describe sql.query('SHOW statement_timeout;', ["#{input('postgres_default_db')}"]) do
    its('output') { should_not cmp '0' }
  end
end
