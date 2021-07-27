#include-once

Func _files_Update_SaveData($file, $data)
	$hResetFileData = FileOpen($file, $FO_OVERWRITE)
	FileWrite($hResetFileData, $data)
	FileClose($hResetFileData)
EndFunc   ;==>_files_Update_SaveData

Func _files_Append_SaveData($file, $data)
	$hResetFileData = FileOpen($file, $FO_APPEND)
	FileWrite($hResetFileData, $data)
	FileClose($hResetFileData)
EndFunc   ;==>_files_Append_SaveData

Func _files_FileContent($asData)
	If IsArray($asData) Then
		Local $sFileLocation = _files_FileLocation($asData)
	Else
		Local $sFileLocation = $asData
	EndIf
	Local $hFileOpen = FileOpen($sFileLocation, $FO_READ)
	Local $sFileRead = FileRead($hFileOpen)
	FileClose($hFileOpen)
	Return $sFileRead
EndFunc   ;==>_files_FileContent

Func _files_FileLocation($aArray)
	Local $sFileAddress = ""
	For $i = 0 To UBound($aArray) - 1 Step +1
		$sFileAddress &= "\" & $aArray[$i]
	Next
	Return @ScriptDir & $sFileAddress & ".txt"
EndFunc   ;==>_files_FileLocation

#include-once

Func _SaveDataToFile($sFile, $sData)
	Local $hFile = FileOpen($sFile, $FO_OVERWRITE + $FO_CREATEPATH)
	FileWrite($hFile, $sData)
	FileClose($hFile)
EndFunc   ;==>_SaveDataToFile

Func _ReadDataFromFile($sFile)
	Local $hFile = FileOpen($sFile, $FO_READ)
	Local $sData = FileRead($hFile)
	FileClose($hFile)
	Return $sData
EndFunc   ;==>_ReadDataFromFile


