# Deploy k8s cluster VMs based on template created by packer

$SubnetMask     = '255.254.0.0'
$Gateway        = '172.30.0.1'
$TemplateName   = 'k8s-photon5'
$CustSpecName   = 'Kubernetes VMs'
$Datastore      = 'vsan Datastore'
$ResourcePool   = 'cl01'
$VMFolder       = 'Kubernetes'

$Nodes = @{
  'cp01' = '172.30.0.11'; 'cp02' = '172.30.0.12'; 'cp03' = '172.30.0.13'
  'wk01' = '172.30.1.11'; 'wk02' = '172.30.1.12'; 'wk03' = '172.30.1.13'
}

$VMTemplate = Get-Template -Name $TemplateName

$Nodes.GetEnumerator() | ForEach-Object {
  Write-Host -ForegroundColor Green ("Deploying node $($_.Key)")
  $spec = Get-OSCustomizationSpec -Name $CustSpecName
  $spec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $($_.Value) -SubnetMask $SubnetMask -DefaultGateway $Gateway
  New-VM -Name $($_.Key) -Template $VMTemplate -ResourcePool $ResourcePool -Location $VMFolder -Datastore $Datastore -OSCustomizationSpec $spec
}
