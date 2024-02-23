class CsvReader{
	[string]$delim
	[string]$escape
	[string]$enclosure
	[System.IO.StreamReader]$file
	[System.Collections.ArrayList]$row= [System.Collections.ArrayList]::new(50)
	CsvReader([string]$delim, [string]$escape, [string]$enclosure){
		$this.delim= $delim
		$this.enclosure= $enclosure
		$this.escape= $escape
	}
	[void] open($file){
		$this.file= [System.IO.StreamReader]::new([System.IO.FileStream]::new($file, [System.IO.FileMode]::Open))
	}
	[void] close(){
		$this.file.Close()
	}
	[bool] isEoF(){
		return $this.file.EndOfStream
	}
	[array] next(){
		[bool]$quoted= $false
		[bool]$double= $this.enclosure -ceq $this.escape
		[int]$cr= 0
		[char]$c= $null
		[int]$cr2= 0
		[char]$c2= $null
		[string]$buf= ''
		$this.row.Clear()
		while(-1 -ne ($cr= $this.file.Read())){
			$c= [char]$cr
			#Write-Host $cr $c
			if(!$quoted){
				if($c -ceq $this.enclosure){
					if($double){
						$cr2= $this.file.Peek()
						if($cr2 -eq -1){
							break;
						}
						$c2= [char]$cr2
						if($c2 -ceq $this.enclosure){
							$buf+= $c2
							continue
						}else{
							$quoted= $true
							#$this.file.Seek(-1, [System.IO.SeekOrigin]::Current)
						}
					}
				}elseif($c -ceq $this.delim){
					$this.row.Add($buf)
					$buf= ''
				}elseif( ($c -eq "`n") -or ($c -eq "`r") ){
					if( ($c -eq "`r") -and (([char]$this.file.Peek()) -eq "`n")){
						$this.file.Read()
					}
					$this.row.Add($buf)
					break
				}else{
					$buf+= $c
				}
			}else{ #quoted
				if($c -eq $this.escape){
					if($double){
						# enclosure and escape are the same
						$cr2= $this.file.Peek()
						if(-1 -eq $cr2){
							$this.row.Add($buf)
							break
						}
						$c2= [char]$cr2
						if($c2 -ne $this.escape){
							$quoted= $false
							continue
						}
					}
					$cr= $this.file.Read()
					if($cr -eq -1){
						$this.row.Add($buf)
						break
					}
					$buf+= [char]$cr
				}elseif($c -ceq $this.enclosure){
					$quoted= $false;
				}else{
					$buf+= $c;
				}
			}
		}
		return $this.row.ToArray()
	}
}
