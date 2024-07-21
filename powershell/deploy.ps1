# Deploy k8s cluster VMs based on template created by packer

$SubnetMask     = '255.254.0.0'
$Gateway        = '172.30.0.1'
$TemplateName   = 'k8s-photon5'
$CustSpecName   = 'Kubernetes VMs'
$Datastore      = 'vsan Datastore'
$ResourcePool   = 'cl01'
$VMFolder       = 'Kubernetes'

$Nodes = @{
  'k8s01-c01' = '172.30.0.11'; 'k8s01-c02' = '172.30.0.12'; 'k8s01-c03' = '172.30.0.13'
  'k8s01-w01' = '172.30.0.14'; 'k8s01-w02' = '172.30.0.15'; 'k8s01-w03' = '172.30.0.16'
}

$VMTemplate = Get-Template -Name $TemplateName

$Nodes.GetEnumerator() | ForEach-Object {
  Write-Host -ForegroundColor Green ("Deploying node $($_.Key)")
  $spec = Get-OSCustomizationSpec -Name $CustSpecName
  $spec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $($_.Value) -SubnetMask $SubnetMask -DefaultGateway $Gateway
  New-VM -Name $($_.Key) -Template $VMTemplate -ResourcePool $ResourcePool -Location $VMFolder -Datastore $Datastore -OSCustomizationSpec $spec
}
