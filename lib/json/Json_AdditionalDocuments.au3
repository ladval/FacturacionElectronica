

Func _JSON_AdditionalDocuments($aArray)
	Local $aJsonData_AdditionalDocuments[22]
	$aJsonData_AdditionalDocuments[0] = '"AdditionalDocuments": {'
	$aJsonData_AdditionalDocuments[1] = '"OrderReference": "",'
	$aJsonData_AdditionalDocuments[2] = '"OrderReferenceIssueDate": "",'
	$aJsonData_AdditionalDocuments[3] = '"DespatchDocumentReference": "",'
	$aJsonData_AdditionalDocuments[4] = '"DespatchDocumentIssueDate": "",'
	$aJsonData_AdditionalDocuments[5] = '"ReceiptDocumentReference": "",'
	$aJsonData_AdditionalDocuments[6] = '"ReceiptDocumentIssueDate": "",'
	$aJsonData_AdditionalDocuments[7] = '"AdditionalDocument": ['
	$aJsonData_AdditionalDocuments[8] = '{'
	$aJsonData_AdditionalDocuments[9] = '"DocumentNumber": "",'
	$aJsonData_AdditionalDocuments[10] = ' "DocumentCode": "",'
	$aJsonData_AdditionalDocuments[11] = ' "DocumentType": "",'
	$aJsonData_AdditionalDocuments[12] = ' "IssueDate": ""'
	$aJsonData_AdditionalDocuments[13] = ' }'
	$aJsonData_AdditionalDocuments[14] = ' ]'
	$aJsonData_AdditionalDocuments[15] = ' },'
	$aJsonData_AdditionalDocuments[16] = ' "AdditionalDocumentReceipt": ['
	$aJsonData_AdditionalDocuments[17] = ' {'
	$aJsonData_AdditionalDocuments[18] = ' "DocumentValue": "",'
	$aJsonData_AdditionalDocuments[19] = ' "IssueDate": "" '
	$aJsonData_AdditionalDocuments[20] = ' }'
	$aJsonData_AdditionalDocuments[21] = ' ],'
	Local $sPedido = ""
	Local $iIndex = 1
	For $i = 1 To UBound($aArray, 2) - 1 Step +1 ;Recorrido de arreglo que define la columna del nit del cliente o del ingreso propio
		Local $sTipoIngreso = StringStripWS($aArray[102][$i], 8)
		If StringInStr($sTipoIngreso, "propio") Then
			Local $iIndex = $i
			ExitLoop
		ElseIf $i = UBound($aArray, 2) - 1 And StringInStr($sTipoIngreso, "propio") Then
			Local $iIndex = $i
			ExitLoop
		ElseIf $i = UBound($aArray, 2) - 1 And StringInStr($sTipoIngreso, "tercero") Then
			Local $iIndex = $i
		EndIf
	Next
	Local $sNit_Cliente = $aArray[2][$iIndex]
	$sNit_Cliente = StringStripWS($sNit_Cliente, 8)
	Switch $sNit_Cliente
		Case "860031028", "900931305", "901191622", "901326481"
			ConsoleWrite("FACTURA DE SIEMENS. Aplica cambios XML." & @CRLF)
			Local $aDataSiemens = _XML_Data_Siemens($aArray)
			If IsArray($aDataSiemens) Then
				Local $sOrdenDeCompra = '"OrderReference": "' & $aDataSiemens[0] & '",'
				Local $sEmbarque = '"DespatchDocumentReference": "' & $aDataSiemens[1] & '",'
				$aJsonData_AdditionalDocuments[1] = StringReplace($sOrdenDeCompra, '\', '')
				$aJsonData_AdditionalDocuments[3] = StringReplace($sEmbarque, '\', '')
				$aJsonData_AdditionalDocuments[7] = '"AdditionalDocument": ['
				$aJsonData_AdditionalDocuments[8] = '{'
				$aJsonData_AdditionalDocuments[9] = '"DocumentNumber": "' & $aArray[83][1] & '",'
				$aJsonData_AdditionalDocuments[10] = ' "DocumentCode": "R",'
				$aJsonData_AdditionalDocuments[11] = ' "DocumentType": "TN",'
				$aJsonData_AdditionalDocuments[12] = ' "IssueDate": ""'
				$aJsonData_AdditionalDocuments[13] = ' }'
				$aJsonData_AdditionalDocuments[14] = ' ]'
				$aJsonData_AdditionalDocuments[15] = ' },'
				$aJsonData_AdditionalDocuments = _ArrayExtract($aJsonData_AdditionalDocuments, 0, 15)
				_ArrayAdd($aJsonData_AdditionalDocuments, '"AdditionalDocumentReceipt": [],')
			Else
				$aJsonData_AdditionalDocuments[7] = '"AdditionalDocument": []'
				$aJsonData_AdditionalDocuments = _ArrayExtract($aJsonData_AdditionalDocuments, 0, 7)
				_ArrayAdd($aJsonData_AdditionalDocuments, '},')
				_ArrayAdd($aJsonData_AdditionalDocuments, '"AdditionalDocumentReceipt": [],')
			EndIf
		Case "890900943"
			$aJsonData_AdditionalDocuments[9] = '"DocumentNumber": "' & $aArray[83][1] & '",'
			$aJsonData_AdditionalDocuments[10] = ' "DocumentCode": "R",'
			$aJsonData_AdditionalDocuments[11] = ' "DocumentType": "PEDIDO",'
			$aJsonData_AdditionalDocuments = _ArrayExtract($aJsonData_AdditionalDocuments, 0, 13)
			_ArrayAdd($aJsonData_AdditionalDocuments, ']')
			_ArrayAdd($aJsonData_AdditionalDocuments, '},')
			_ArrayAdd($aJsonData_AdditionalDocuments, '"AdditionalDocumentReceipt": [],')
		Case Else
			$aJsonData_AdditionalDocuments[7] = '"AdditionalDocument": []'
			$aJsonData_AdditionalDocuments[8] = '},'
			$aJsonData_AdditionalDocuments = _ArrayExtract($aJsonData_AdditionalDocuments, 0, 8)
	EndSwitch

	Return $aJsonData_AdditionalDocuments
EndFunc   ;==>_JSON_AdditionalDocuments

Func _XML_Data_Siemens($aArray)
	Local $sOrdenDeCompra = ""
	Local $sEmbarque = ""
	Local $aDataSiemens[2]
	Local $sObservaciones = $aArray[111][1]
	Local $aObservaciones = StringSplit($sObservaciones, "'", 3)
	For $i = 0 To UBound($aObservaciones) - 1 Step +1
		Local $sObsArrayLine = $aObservaciones[$i]
		If StringInStr($sObsArrayLine, "oc ") Then
			Local $sOrdenDeCompra = StringReplace($sObsArrayLine, "oc ", "")
			$sOrdenDeCompra = StringStripWS($sOrdenDeCompra, 8)
		EndIf
		If StringInStr($sObsArrayLine, "embarque ") Then
			Local $sEmbarque = StringReplace($sObsArrayLine, "embarque ", "")
			$sEmbarque = StringStripWS($sEmbarque, 8)
		EndIf
		If StringInStr($sObsArrayLine, "ea ") Then
			Local $sEmbarque = StringReplace($sObsArrayLine, "ea ", "")
			$sEmbarque = StringStripWS($sEmbarque, 8)
		EndIf
	Next
	If StringLen($sOrdenDeCompra) = 0 And StringLen($sEmbarque) = 0 Then Return False
	Local $aResponse[2] = [$sOrdenDeCompra, $sEmbarque]
	Return $aResponse
EndFunc   ;==>_XML_Data_Siemens



