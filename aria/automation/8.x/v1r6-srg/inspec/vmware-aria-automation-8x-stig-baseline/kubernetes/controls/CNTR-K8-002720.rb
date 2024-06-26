control 'CNTR-K8-002720' do
  title 'Kubernetes must contain the latest updates as authorized by IAVMs, CTOs, DTMs, and STIGs.'
  desc 'Kubernetes software must stay up to date with the latest patches, service packs, and hot fixes. Not updating the Kubernetes control plane will expose the organization to vulnerabilities.

Flaws discovered during security assessments, continuous monitoring, incident response activities, or information system error handling must also be addressed expeditiously.

Organization-defined time periods for updating security-relevant container platform components may vary based on a variety of factors including, for example, the security category of the information system or the criticality of the update (i.e., severity of the vulnerability related to the discovered flaw).

This requirement will apply to software patch management solutions that are used to install patches across the enclave and also to applications themselves that are not part of that patch management solution. For example, many browsers today provide the capability to install their own patch software. Patch criticality, as well as system criticality will vary. Therefore, the tactical situations regarding the patch management process will also vary. This means that the time period utilized must be a configurable parameter. Time frames for application of security-relevant software updates may be dependent upon the IAVM process.

The container platform components will be configured to check for and install security-relevant software updates within an identified time period from the availability of the update. The container platform registry will ensure the images are current. The specific time period will be defined by an authoritative source (e.g., IAVM, CTOs, DTMs, and STIGs).'
  desc 'check', 'Authenticate on the Kubernetes Control Plane. Run the command:
kubectl version --short

If kubectl version has a setting not supporting Kubernetes skew policy, this is a finding.

Note: Kubernetes Skew Policy can be found at: https://kubernetes.io/docs/setup/release/version-skew-policy/#supported-versions'
  desc 'fix', 'Upgrade Kubernetes to the supported version. Institute and adhere to the policies and procedures to ensure that patches are consistently applied within the time allowed.'
  impact 0.5
  ref 'DPMS Target Kubernetes'
  tag check_id: 'C-45718r863908_chk'
  tag severity: 'medium'
  tag gid: 'V-242443'
  tag rid: 'SV-242443r879827_rule'
  tag stig_id: 'CNTR-K8-002720'
  tag gtitle: 'SRG-APP-000456-CTR-001125'
  tag fix_id: 'F-45676r712684_fix'
  tag 'documentable'
  tag cci: ['CCI-002635']
  tag nist: ['SI-3 (10) (a)']

  kubeconfig = input('kubectl_conf_path')

  # https://kubernetes.io/releases/version-skew-policy/#kubelet
  # Skew policy for kubelet is within 2 minor version of api-server i.e. if server is 1.22.x then client 1.20.x, 1.21.x, and 1.22.x are all valid
  # In 1.28 and above --short is deprecated
  kubectl_cmd = "(kubectl version --short --kubeconfig=#{kubeconfig} || kubectl version --kubeconfig=#{kubeconfig})2>/dev/null"
  server_version = Semverse::Version.new(bash("#{kubectl_cmd} | grep -i server | awk -F': ' '{ print $2 }' | sed s/^v//").stdout.chomp)
  client_version = Semverse::Version.new(bash("#{kubectl_cmd} | grep -i client | awk -F': ' '{ print $2 }' | sed s/^v//").stdout.chomp)

  server_version_major = server_version.major
  server_version_minor = server_version.minor

  client_version_major = client_version.major
  client_version_minor = client_version.minor

  allowed_client_version = Semverse::Version.new("#{client_version_major}.#{client_version_minor}")
  describe.one do
    describe allowed_client_version do
      it { should cmp Semverse::Version.new("#{server_version_major}.#{server_version_minor}") }
    end
    describe allowed_client_version do
      it { should cmp Semverse::Version.new("#{server_version_major}.#{server_version_minor - 1}") }
    end
    describe allowed_client_version do
      it { should cmp Semverse::Version.new("#{server_version_major}.#{server_version_minor - 2}") }
    end
  end
end
