# Prompt for XML file name and read in XML file, to an XML Object
$inputFile = Read-Host -Prompt 'Enter XML file name'
[xml]$inputXML = Get-Content $inputFile -Encoding:UTF8
$xmlSize = $inputXML.ChildNodes.application.Count
$fileOutput = @()

# iterate through XML Object
for($i=1; $i -lt $xmlSize; ++$i)
{
	# Clear IP and Port
	$IPAddress = ''
	$Port = ''
	
	# Set the Software Service Name and Analyzer
	$SSName = $inputXML.ChildNodes.application[$i].name	
	$analyzer = $inputXML.ChildNodes.application[$i].analyzer.ChildNodes.ToString()
	
	# Variable used to check if IP addresses and ports have been found, and need to be written to the new file
	$write = 0
	
	# Grab the child nodes that contain the IP and Port information from the XML that has been read in	
	$SSArray = $inputXML.ChildNodes.application[$i].report.service.innerXML

	# Iterate through XML array
	for($b=0; $b -lt $SSArray.count; ++$b)
	{
	
		#If there is only one IP:Port combination, it can come through as a single line. This reads it as a string in that case
		if($SSArray.count -eq 1)
		{
			# Switch statement checking if it's an IP or IP Range
			Switch -regex ($SSArray)
			{
				"<ip>.*"
				{
					# Splits the array into separate secions based on when tags start and end
					$fullLine = $SSArray -Split '><'
					
					# Trim the IP Address to remove the tags on either side
					$tempString = $fullLine[0] -Replace "<ip>", ''
					$IPAddress = $tempString -Replace "</ip", ''
					
					# Check if it's a port range or single port
					if($fullLine[1] -eq "portRange")
					{
						# Trim the tags on either side of the ports and then add them together to be in the format [Port1] - [Port2]
						$tempString = $fullLine[2] -Replace "b>", ''
						$Port1 = $tempString -Replace "</b", ''
						$tempString = $fullLine[3] -Reaplce "e>", ''
						$Port2 = $tempString -Replace "</e", ''
						$Port = $Port1 + " - " $Port2
					}
					else {
						# Trim the port tags
						$tempString = $fullLine[1] -Replace "port>", ''
						$Port = $tempString -Replace "</", ''
					}
					# Change the write counter to 1 (0 means don't write, 1 means write)
					$write = 1
				}
				"<ipRange>.*"
				{
					# Splits the array into separate secions based on when tags start and end
					$fullLine = $SSArray -Split '><'
					
					# Trim the tags on either side of the IP addresses and add them in the format [IPAddress1] - [IPAddress2]
					$tempString = $fullLine[1] -Replace "b>", ''
					$IPAddress1 = $tempString -Replace "</b", ''
					$tempString = $fullLine[2] -Replace "e>", ''
					$IPAddress2 = $tempString -Replace "</e", ''
					$IPAddress = $IPAddress1 + " - " + $IPAddress2
					
					# Check if it's a port range or single port
					if($fullLine[4] -eq "portRange")
					{
						# Trim the tags on either side of the ports and then add them together to be in the format [Port1] - [Port2]
						$tempString = $fullLine[5] -Replace "b>", ''
						$Port1 = $tempString -Replace "</b", ''
						$tempString = $fullLine[6] -Reaplce "e>", ''
						$Port2 = $tempString -Replace "</e", ''
						$Port = $Port1 + " - " $Port2
					}
					else {
						# Trim the port tags
						$tempString = $fullLine[4] -Replace "port>", ''
						$Port = $tempString -Replace "</", ''
					}
					# Change the write counter to 1 (0 means don't write, 1 means write)
					$write = 1
				}
			}
		}
		else {
			# Switch statement checking if it's an IP or IP Range
			Switch -regex ($SSArray[$b])
			{
				"<ip>.*"
				{
					# Splits the array into separate secions based on when tags start and end
					$fullLine = $SSArray[$b] -Split '><'
					
					# Trim the IP Address to remove the tags on either side
					$tempString = $fullLine[0] -Replace "<ip>", ''
					$IPAddress = $tempString -Replace "</ip", ''
					
					# Check if it's a port range or single port
					if($fullLine[1] -eq "portRange")
					{
						# Trim the tags on either side of the ports and then add them together to be in the format [Port1] - [Port2]
						$tempString = $fullLine[2] -Replace "b>", ''
						$Port1 = $tempString -Replace "</b", ''
						$tempString = $fullLine[3] -Reaplce "e>", ''
						$Port2 = $tempString -Replace "</e", ''
						$Port = $Port1 + " - " $Port2
					}
					else {
						# Trim the port tags
						$tempString = $fullLine[1] -Replace "port>", ''
						$Port = $tempString -Replace "</", ''
					}
					# Change the write counter to 1 (0 means don't write, 1 means write)
					$write = 1
				}
				"<ipRange>.*"
				{
					# Splits the array into separate secions based on when tags start and end
					$fullLine = $SSArray[$b] -Split '><'
					
					# Trim the tags on either side of the IP addresses and add them in the format [IPAddress1] - [IPAddress2]
					$tempString = $fullLine[1] -Replace "b>", ''
					$IPAddress1 = $tempString -Replace "</b", ''
					$tempString = $fullLine[2] -Replace "e>", ''
					$IPAddress2 = $tempString -Replace "</e", ''
					$IPAddress = $IPAddress1 + " - " + $IPAddress2
					
					# Check if it's a port range or single port
					if($fullLine[4] -eq "portRange")
					{
						# Trim the tags on either side of the ports and then add them together to be in the format [Port1] - [Port2]
						$tempString = $fullLine[5] -Replace "b>", ''
						$Port1 = $tempString -Replace "</b", ''
						$tempString = $fullLine[6] -Reaplce "e>", ''
						$Port2 = $tempString -Replace "</e", ''
						$Port = $Port1 + " - " $Port2
					}
					else {
						# Trim the port tags
						$tempString = $fullLine[4] -Replace "port>", ''
						$Port = $tempString -Replace "</", ''
					}
					# Change the write counter to 1 (0 means don't write, 1 means write)
					$write = 1
				}
			}
		}
		# If the write counter doesn't equal 0, write to file
		if($write -ne 0)
		{
			# Create a row object, where we will set column names, then add to an output array
			$row = New-Object PSObject
			$row | Add-Member -MemberType NoteProperty -Name 'Software Service' -Value $SSName
			$row | Add-Member -MemberType NoteProperty -Name 'Analyzer' -Value $analyzer
			$row | Add-Member -MemberType NoteProperty -Name 'IP Address' -Value $IPAddress
			$row | Add-Member -MemberType NoteProperty -Name 'Port' -Value $Port
			$fileOutput += $row
		}
	}
}

# Prompt for output file name and then export the output array to a CSV
$outputName = Read-Host -Prompt 'Enter name for output CSV file'
$fileOutput | Export-CSV $outputName -NoTypeInformation
