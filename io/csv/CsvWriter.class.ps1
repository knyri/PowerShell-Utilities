class CsvWriter{
	[string]$delim
	[string]$escape
	[string]$enclosure
	[string]$escapeEscape
	[string]$enclosureEscape
	[bool]$newRow= $true
	[bool]$doubleEnclosure
	[System.IO.StreamWriter]$file
	CsvWriter([string]$delim, [string]$escape, [string]$enclosure){
		$this.delim= $delim
		$this.enclosure= $enclosure
		$this.doubleEnclosure= $enclosure -ceq $escape
		$this.escape= $escape
		$this.enclosureEscape= $escape + $enclosure
		$this.escapeEscape= $escape + $escape
	}
	[void] open($file){
		$this.file= [System.IO.StreamWriter]::new([System.IO.FileStream]::new($file, [System.IO.FileMode]::OpenOrCreate))
	}
	[void] close(){
		$this.file.Close()
	}
	[void] endRow(){
		$this.file.Write($this.file.NewLine)
		$this.newRow= $true
	}
	[void] write([string]$v){
		if($this.newRow){
			$this.newRow= $false
		}else{
			$this.file.Write(",")
		}
		$this.file.Write('"')
		if($this.doubleEnclosure){
			$this.file.Write(($v.Replace($this.enclosure,$this.enclosureEscape)))
		}else{
			$this.file.Write(
				$v.Replace($this.escape,$this.escapeEscape).Replace($this.enclosure,$this.enclosureEscape)
			)
		}
		$this.file.Write('"')
	}
	[void] writeRow([array]$row){
		foreach($v in $row){
			$this.write($v)
		}
		$this.endRow()
	}
}