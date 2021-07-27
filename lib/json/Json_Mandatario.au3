
Func _InvoiceMandateInformation($aArrayAllData, $iSearchIndexData)
	Local $sRegistrationName = ""
	Local $IdentificationType = $aArrayAllData[1][$iSearchIndexData+ 1]             ;CUANDO EL INGRESO ES TERCERO, CORRESPONDE AL MANDANTE
	Local $Identification = $aArrayAllData[2][$iSearchIndexData+ 1]                 ;IdentificationType
	Local $sDV = NitCV_Calculator($aArrayAllData[2][$iSearchIndexData + 1])
	If StringInStr($aArrayAllData[102][$iSearchIndexData + 1], "propi") > 0 Then
		Local $sRegistrationName = "MANDANTE"                             ;PROPIO
	Else
		Local $sRegistrationName = "MANDATARIO"                       ;TERCERO
	EndIf
	Local $aInvoiceMandante[8]
	$aInvoiceMandante[0] = '"InvoiceMandateInformation": {'
	$aInvoiceMandante[1] = '"Mandate": {'
	$aInvoiceMandante[2] = '"IdentificationType": ' & $aArrayAllData[1][$iSearchIndexData + 1] & ','
	$aInvoiceMandante[3] = '"Identification": ' & $aArrayAllData[2][$iSearchIndexData + 1] & ','
	$aInvoiceMandante[4] = '"RegistrationName": "' & $sRegistrationName & '",'
	$aInvoiceMandante[5] = '"DV": ' & NitCV_Calculator($aArrayAllData[2][$iSearchIndexData + 1]) & ''
	$aInvoiceMandante[6] = '}'
	$aInvoiceMandante[7] = '}'
	Return $aInvoiceMandante
EndFunc   ;==>_InvoiceMandateInformation
