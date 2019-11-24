function Get-VSSWriter {
    [CmdletBinding()]

    Param (
        [ValidateSet('Stable', 'Failed')]
        [String] 
        $Status
    ) #Param

    BEGIN { } #BEGIN

    PROCESS {
        
        #Command to retrieve all writers, and split them into groups
        VSSAdmin list writers | 
        Select-String -Pattern 'Writer name:' -Context 0, 4 |
        ForEach-Object {

            #Extracting exact values
            $Name = $_.Line -replace "^(.*?): " -replace "'"
            $Id = $_.Context.PostContext[0] -replace "^(.*?): "
            $InstanceId = $_.Context.PostContext[1] -replace "^(.*?): "
            $State = $_.Context.PostContext[2] -replace "^(.*?): "
            $LastError = $_.Context.PostContext[3] -replace "^(.*?): "

            #Create object
            foreach ($Prop in $_) {
                $Obj = [pscustomobject]@{
                    Name       = $Name
                    Id         = $Id
                    InstanceId = $InstanceId
                    State      = $State
                    LastError  = $LastError
                } 
            }#foreach  

            #Change output based on Status provided
            If ($PSBoundParameters.ContainsKey('Status')) {
                $Obj | Where-Object { $_.State -like "*$Status" }
            } #if
            else {
                $Obj
            } #else

        }#foreach-object

    } #PROCESS

    END { } #END


}#function

function Restart-VSSWriter {
    [CmdletBinding()]

    Param (
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True, Mandatory = $True)]
        [String] 
        $Name
    ) #Param

    BEGIN { } #Begin

    PROCESS {

        Switch ($Name) {
            'ASR Writer' { $Service = 'VSS' }
            'BITS Writer' { $Service = 'BITS' }
            'Certificate Authority' { $Service = 'EventSystem' }
            'COM+ REGDB Writer' { $Service = 'VSS' }
            'DFS Replication service writer' { $Service = 'DFSR' }
            'DHCP Jet Writer' { $Service = 'DHCPServer' }
            'FRS Writer' { $Service = 'NtFrs' }
            'FSRM writer' { $Service = 'srmsvc' }
            'IIS Config Writer' { $Service = 'AppHostSvc' }
            'IIS Metabase Writer' { $Service = 'IISADMIN' }
            'Microsoft Exchange Writer' { $Service = 'MSExchangeIS' }
            'Microsoft Hyper-V VSS Writer' { $Service = 'vmms' }
            'NTDS' { $Service = 'NTDS' }
            'OSearch VSS Writer' { $Service = 'OSearch' }
            'OSearch14 VSS Writer' { $Service = 'OSearch14' }
            'Registry Writer' { $Service = 'VSS' }
            'Shadow Copy Optimization Writer' { $Service = 'VSS' }
            'SPSearch VSS Writer' { $Service = 'SPSearch' }
            'SPSearch4 VSS Writer' { $Service = 'SPSearch4' }
            'SqlServerWriter' { $Service = 'SQLWriter' }
            'System Writer' { $Service = 'CryptSvc' }
            'TermServLicensing' { $Service = 'TermServLicensing' }
            'WINS Jet Writer' { $Service = 'WINS' }
            'WMI Writer' { $Service = 'Winmgmt' }
            default {$Null = $Service}
        } #Switch

        IF ($Service) {
            $S = Get-Service -Name $Service
            Write-Host "Restarting service $(($S).DisplayName)"
            $S | Restart-Service -Force
        }
        ELSE {
            Write-Warning "No service associated with VSS Writer: $Name"
        }

    } #PROCESS

    END { } #END
}#function