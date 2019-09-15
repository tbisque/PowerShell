$Name = "4 vCPU, 16GB RAM, 20GB HDD"

Get-Template | 
    Where-Object name -match $Name | 
        Get-View | 
            Select-Object config -ExpandProperty config