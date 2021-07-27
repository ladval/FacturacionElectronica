#include-once
#include "lib\lib_sql.au3"
;============================================================================================================================
Func _ModuloSQL_SQL_Conn()
	Local $sJsonFileSettings = @ScriptDir & "\settings\settings.json"
	Local $sJsonSettings = _ReadDataFromFile($sJsonFileSettings)
	Local $oJsonSettings = Json_Decode($sJsonSettings)
	Local $sSQL_Conn = Json_Get($oJsonSettings, ".conn.db_conn")
	Local $Instancia = Json_Get($oJsonSettings, ".conn." & $sSQL_Conn & "[0].Instancia")
	Local $BD = Json_Get($oJsonSettings, ".conn." & $sSQL_Conn & "[1].BD")
	Local $Usuario = Json_Get($oJsonSettings, ".conn." & $sSQL_Conn & "[2].Usuario")
	Local $Clave = Json_Get($oJsonSettings, ".conn." & $sSQL_Conn & "[3].Clave")
	_SQL_RegisterErrorHandler()     ;register the error handler to prevent hard crash on COM error
	$oADODB = _SQL_Startup()
	If $oADODB = $SQL_ERROR Then MsgBox(0 + 16 + 262144, "Error", _SQL_GetErrMsg())
	$iConn = _SQL_Connect(-1, $Instancia, $BD, $Usuario, $Clave)
	If $iConn = $SQL_OK Then
		Return $iConn
	Else
		Return $SQL_ERROR
	EndIf
EndFunc   ;==>_ModuloSQL_SQL_Conn
;============================================================================================================================
Func _ModuloSQL_SQL_SELECT($Query)
	_ModuloSQL_SQL_Conn()
	Local $aData = ""
	Local $iRows, $iColumns
	$iRval = _SQL_GetTable2D(-1, $Query, $aData, $iRows, $iColumns)
	If $iRval = $SQL_OK Then
		_SQL_Close()
		Return $aData
	Else
		_SQL_Close()
		Return $iRval
	EndIf
EndFunc   ;==>_ModuloSQL_SQL_SELECT
;~ ;============================================================================================================================
Func _ModuloSQL_SQL_EXEC($Query)
	_ModuloSQL_SQL_Conn()
	Local $aData = ""
	$iCUval = _SQL_Execute(-1, $Query)
	If $iCUval = $SQL_OK Then
		_SQL_Close()
		Return $aData
	Else
		_SQL_Close()
		Return $iCUval
	EndIf
EndFunc   ;==>_ModuloSQL_SQL_EXEC
;================================================================================================================================
