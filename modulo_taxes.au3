Global $iColIndex = 9

Func _JsonItemTaxesData($aJsonDataArray)
	Local $aTaxesData = _TaxesData($aJsonDataArray)
	Local $aTaxesDetailed = _TaxesDetailed($aTaxesData, $aJsonDataArray)
	If StringStripWS(StringUpper($aJsonDataArray[69][1]), 8) == 'COP' Then
		Local $iTasaCambio = 1
	Else
		Local $iTasaCambio = $aJsonDataArray[76][1]
	EndIf
	Local $aItemTaxes = $aTaxesDetailed[0]
	Local $sJsonItemInfo = ""
	$sJsonItemInfo &= '"ItemInformation": [' & @CRLF
	For $j = 1 To UBound($aJsonDataArray, 2) - 1 Step +1
		Local $sItemInfo_ItemReference = StringReplace($aJsonDataArray[23][$j], '"', "''''")
		$sItemInfo_ItemReference = StringReplace($aJsonDataArray[23][$j], "'", "''")
		Local $sItemInfo_Name = _ItemName($aJsonDataArray[24][$j])
		Local $sItemInfo_Quatity = $aJsonDataArray[25][$j]
		Local $iItemInfo_Price = Round($aJsonDataArray[26][$j] / $iTasaCambio, 2)
		Local $iItemInfo_LineTotalTaxes = _ItemInfo_LineTotalTaxes($aItemTaxes, $j)
		Local $iItemInfo_LineExtensionAmount = Round(($sItemInfo_Quatity * $aJsonDataArray[26][$j]) / $iTasaCambio, 2)
		Local $iItemInfo_LineTotal = Round(($iItemInfo_LineExtensionAmount + $iItemInfo_LineTotalTaxes) / $iTasaCambio)
		Local $sItemInfo_MeasureUnitCode = _MeasureUnitCode($aJsonDataArray[28][$j])
		Local $sItemInfo_FreeOFChargeIndicator = "false"
		Local $sItemInfo_TipoIngreso = _ItemInfo_TipoIngreso($aTaxesData, $j)
		$sItemInfo_TipoIngreso = StringTrimRight($sItemInfo_TipoIngreso, 1)
		Local $sItemInfoMandate_IdentificationType = ""
		Local $sItemInfoMandate_Identification = ""
		Local $sItemInfoMandate_RegistrationName = ""
		Local $sItemInfoMandate_DV = '""'
		If _ItemInfo_TipoIngreso($aItemTaxes, $j) == "PROPIOG" Then
			Local $sItemInfoMandate_IdentificationType = $aJsonDataArray[1][$j]
			Local $sItemInfoMandate_Identification = $aJsonDataArray[2][$j]
			Local $sItemInfoMandate_RegistrationName = $aJsonDataArray[6][$j]
			Local $sItemInfoMandate_DV = NitCV_Calculator($aJsonDataArray[2][$j])
		EndIf
		$sJsonItemInfo &= '{' & @CRLF
		$sJsonItemInfo &= '"ItemReference": "' & $sItemInfo_ItemReference & '",' & @CRLF
		$sJsonItemInfo &= '"Name": "' & $sItemInfo_Name & '",' & @CRLF
		$sJsonItemInfo &= '"Quatity": ' & $sItemInfo_Quatity & ',' & @CRLF
		$sJsonItemInfo &= '"Price": ' & $iItemInfo_Price & ',' & @CRLF
		$sJsonItemInfo &= '"LineAllowanceTotal": 0.0, ' & @CRLF
		$sJsonItemInfo &= '"LineChargeTotal": 0.0, ' & @CRLF
		$sJsonItemInfo &= '"LineTotalTaxes": ' & $iItemInfo_LineTotalTaxes & ',' & @CRLF
		$sJsonItemInfo &= '"LineTotal": ' & $iItemInfo_LineTotal & ',' & @CRLF
		$sJsonItemInfo &= '"LineExtensionAmount": ' & $iItemInfo_LineExtensionAmount & ',' & @CRLF
		$sJsonItemInfo &= '"MeasureUnitCode":"' & Round($sItemInfo_MeasureUnitCode, 2) & '", ' & @CRLF
		$sJsonItemInfo &= '"FreeOFChargeIndicator": ' & Round($sItemInfo_FreeOFChargeIndicator, 2) & ',' & @CRLF
		$sJsonItemInfo &= '"AdditionalReference":[],' & @CRLF
		$sJsonItemInfo &= '"AdditionalProperty": [' & @CRLF
		$sJsonItemInfo &= '{' & @CRLF
		$sJsonItemInfo &= '"Name": "Tipo de Ingreso",' & @CRLF
		$sJsonItemInfo &= '"Value": "' & $sItemInfo_TipoIngreso & '"' & @CRLF
		$sJsonItemInfo &= '}' & @CRLF
		$sJsonItemInfo &= '],' & @CRLF
		$sJsonItemInfo &= '"TaxesInformation": [' & _JsonInvoiceTaxItem($aItemTaxes, $j) & '],' & @CRLF
		$sJsonItemInfo &= '"AllowanceCharge": [],' & @CRLF
		$sJsonItemInfo &= '"InvoiceMandateInformation": {' & @CRLF
		$sJsonItemInfo &= '"Mandate": {' & @CRLF
		$sJsonItemInfo &= '"IdentificationType": "' & $sItemInfoMandate_IdentificationType & '",' & @CRLF
		$sJsonItemInfo &= '"Identification": "' & $sItemInfoMandate_Identification & '",' & @CRLF
		$sJsonItemInfo &= '"RegistrationName":"' & $sItemInfoMandate_RegistrationName & '",' & @CRLF
		$sJsonItemInfo &= '"DV": ' & $sItemInfoMandate_DV & @CRLF
		$sJsonItemInfo &= '}' & @CRLF
		$sJsonItemInfo &= '}' & @CRLF
		If $j = UBound($aJsonDataArray, 2) - 1 Then
			$sJsonItemInfo &= '}' & @CRLF
		Else
			$sJsonItemInfo &= '},' & @CRLF
		EndIf
	Next
	$sJsonItemInfo &= '],' & @CRLF
	Local $aTotalTaxes = $aTaxesDetailed[1]
	Local $sJsonInvoiceTaxTotal = _JsonInvoiceTaxTotal($aTotalTaxes)
	Local $sInvoiceOthersOwn = _TaxesDetailed($aTaxesData, $aJsonDataArray, "InvoiceOthersOwn")
	Local $sInvoiceTotal = _TaxesDetailed($aTaxesData, $aJsonDataArray, "InvoiceTotal")
	Local $sJsonItemTaxesData = $sJsonItemInfo & $sJsonInvoiceTaxTotal & $sInvoiceOthersOwn & $sInvoiceTotal
	Local $aJsonItemTaxesData = StringSplit($sJsonItemTaxesData, @CRLF, 3)
	Return $aJsonItemTaxesData
EndFunc   ;==>_JsonItemTaxesData

Func _JsonInvoiceTaxTotal($aTotalTaxes)
	_ArraySort($aTotalTaxes, Default, Default, Default, 1)
	Local $sJsonInvoiceTaxTotal
	$sJsonInvoiceTaxTotal &= '"InvoiceTaxTotal": ['
	For $i = 0 To UBound($aTotalTaxes) - 1 Step +1
		Local $sJsonStructure = ""
		Local $sId = $aTotalTaxes[$i][1]
		Local $sTaxEvidenceIndicator = $aTotalTaxes[$i][2]
		Local $iTaxableAmount = $aTotalTaxes[$i][4]
		Local $iPercent = $aTotalTaxes[$i][6]
		Local $iTaxAmount = $aTotalTaxes[$i][7]
		If $iTaxAmount > 0 Then
			$sJsonStructure &= '{' & @CRLF
			$sJsonStructure &= '"Id": "' & $sId & '",' & @CRLF
			$sJsonStructure &= '"TaxEvidenceIndicator": ' & $sTaxEvidenceIndicator & ',' & @CRLF
			$sJsonStructure &= '"TaxableAmount": ' & Round($iTaxableAmount, 2) & ',' & @CRLF
			$sJsonStructure &= '"TaxAmount": ' & Round($iTaxAmount, 2) & ',' & @CRLF
			$sJsonStructure &= '"Percent": ' & Round($iPercent, 2) & ',' & @CRLF
			$sJsonStructure &= '"BaseUnitMeasure": "",' & @CRLF
			$sJsonStructure &= '"PerUnitAmount": ""' & @CRLF
			If $i = UBound($aTotalTaxes) - 1 Then
				$sJsonStructure &= '}' & @CRLF
			Else
				$sJsonStructure &= '},' & @CRLF
			EndIf
		EndIf
		$sJsonInvoiceTaxTotal &= $sJsonStructure
	Next
	$sJsonInvoiceTaxTotal &= '],' & @CRLF
	Return $sJsonInvoiceTaxTotal
EndFunc   ;==>_JsonInvoiceTaxTotal

Func _JsonInvoiceTaxItem($aItemTaxes, $iItem)
	_ArraySort($aItemTaxes, Default, Default, Default, 1)
	Local $sJsonStructure = ""
	For $i = 0 To UBound($aItemTaxes) - 1 Step +1
		If $aItemTaxes[$i][0] = $iItem Then
			Local $sId = $aItemTaxes[$i][1]
			If $sId = "01" Or $sId = "06" Then
				Local $sTaxEvidenceIndicator = $aItemTaxes[$i][2]
				Local $iTaxableAmount = $aItemTaxes[$i][4]
				Local $iPercent = $aItemTaxes[$i][6]
				Local $iTaxAmount = $aItemTaxes[$i][7]
				If $iTaxAmount > 0 Then
					$sJsonStructure &= '{'
					$sJsonStructure &= '"Id": "' & $sId & '",'
					$sJsonStructure &= '"TaxEvidenceIndicator": ' & $sTaxEvidenceIndicator & ','
					$sJsonStructure &= '"TaxableAmount": ' & $iTaxableAmount & ','
					$sJsonStructure &= '"TaxAmount": ' & $iTaxAmount & ','
					$sJsonStructure &= '"Percent": ' & $iPercent & ','
					$sJsonStructure &= '"BaseUnitMeasure": "",'
					$sJsonStructure &= '"PerUnitAmount": ""'
					$sJsonStructure &= '},'
				EndIf
			EndIf
		EndIf
	Next
	If StringLen($sJsonStructure) > 0 Then $sJsonStructure = StringTrimRight($sJsonStructure, 1)
	Return $sJsonStructure
EndFunc   ;==>_JsonInvoiceTaxItem

Func _ItemInfo_TipoIngreso($aTaxesData, $iIndex)
	Local $sTipoIngreso = 0
	For $i = 3 To UBound($aTaxesData) - 1 Step +1
		If $iIndex = $aTaxesData[$i][7] Then
			$sTipoIngreso = $aTaxesData[$i][6]
			ExitLoop
		EndIf
	Next
	If $sTipoIngreso == "IngresoPropio" Then
		Local $sResponse = "PROPIOG" ;SE AGREGA CARACTER ADICIONAL QUE SE REMUEVE POSTERIORMENTE PARA DISCRIMINAR SUB TIPO DE INGRESO
		Return $sResponse
	ElseIf $sTipoIngreso == "IngresoPropioExcluido" Then
		Local $sResponse = "PROPIOE"
		Return $sResponse
	EndIf
	Local $sResponse = "TERCERO1"
	Return $sResponse
EndFunc   ;==>_ItemInfo_TipoIngreso

Func _ItemInfo_LineTotalTaxes($aItemTaxes, $iItemID)
	For $i = 0 To UBound($aItemTaxes) - 1 Step +1
		If $iItemID = Number($aItemTaxes[$i][0]) And $aItemTaxes[$i][1] = "01" Then
			Return $aItemTaxes[$i][7]
		EndIf
	Next
	Return 0
EndFunc   ;==>_ItemInfo_LineTotalTaxes

Func _TaxesDetailed($aTaxesData, $aJsonDataArray, $sInfoType = "DETAILS")
	Local $aIVA
	Local $aICA
	Local $aReteIVA
	Local $aRetefuente
	Local $aIvaGnralData
	Local $aRtfExcGnralData
	Local $aRtfPropGnralData
	Local $aTaxesDetail[0][$iColIndex]
	Local $aTaxesGeneral[0][$iColIndex]
	Local $iIngresosGravadosTotal = _Calc_IngresosGravados_Total($aTaxesData)
	Local $iIngresosExcluidosTotal = _Calc_IngresosExcluidos_Total($aTaxesData)
	Local $iIngresosTercerosTotal = _Calc_IngresosTerceros_Total($aTaxesData)
	Local $iRtfTotal = _Calc_Rtf_Total($aTaxesData)
	If $aTaxesData[0][7] == "900174994" Then ;VALIDACION EXPRESS
		Local $iRtfPropiosTotal = _Calc_RtfPropios_Total($aTaxesData)
		Local $iRtfExcluidos = $iRtfTotal - $iRtfPropiosTotal
	Else
		Local $iRtfPropiosTotal = _Calc_RtfPropios_Total($aTaxesData)
		Local $iRtfExcluidos = $iRtfTotal - $iRtfPropiosTotal
	EndIf
	If $aJsonDataArray[51][1] > 0 Then
		If StringStripWS(StringUpper($aJsonDataArray[69][1]), 8) == 'COP' Then
			Local $iTasaCambio = 1
		Else
			Local $iTasaCambio = $aJsonDataArray[76][1]
		EndIf
		Local $iIVATotal = Number($aJsonDataArray[51][1]) / Number($iTasaCambio)
		$iIVATotal = _CheckNegative($iIVATotal)
	Else
		Local $iIVATotal = 0
	EndIf
	Local $iRtICATotal = _Calc_RtICA_Total($aTaxesData)
	Local $iRtIVATotal = _Calc_RtIVA_Total($aTaxesData)
	Local $aArrayData[10]
	$aArrayData[0] = $aTaxesData
	$aArrayData[1] = $iIngresosGravadosTotal
	$aArrayData[2] = $iIngresosExcluidosTotal
	$aArrayData[3] = $iIngresosTercerosTotal
	$aArrayData[4] = $iRtfPropiosTotal
	$aArrayData[5] = $iRtfTotal
	$aArrayData[6] = $iRtfExcluidos
	$aArrayData[7] = $iIVATotal
	$aArrayData[8] = $iRtICATotal
	$aArrayData[9] = $iRtIVATotal

	If $sInfoType = "InvoiceOthersOwn" Then
		Local $sJsonInvoiceOthersOwn
		$sJsonInvoiceOthersOwn &= '"InvoiceAllowanceCharge" :[],' & @CRLF
		$sJsonInvoiceOthersOwn &= '"InvoiceTotalOwn" : {' & @CRLF
		$sJsonInvoiceOthersOwn &= '"LineExtensionAmount" : ' & Round($iIngresosGravadosTotal + $iIngresosExcluidosTotal, 2) & ',' & @CRLF
		$sJsonInvoiceOthersOwn &= '"TaxExclusiveAmount" : ' & Round($iIngresosGravadosTotal, 2) & ',' & @CRLF
		$sJsonInvoiceOthersOwn &= '"TaxAmount" : ' & Round($iIVATotal, 2) & ',' & @CRLF
		$sJsonInvoiceOthersOwn &= '"PayableAmount" : ' & Round($iIngresosGravadosTotal + $iIngresosExcluidosTotal + $iIVATotal, 2) & @CRLF
		$sJsonInvoiceOthersOwn &= '},' & @CRLF
		$sJsonInvoiceOthersOwn &= '"InvoiceTotalOthers" : {' & @CRLF
		$sJsonInvoiceOthersOwn &= '"LineExtensionAmount" : ' & Round($iIngresosTercerosTotal, 2) & ',' & @CRLF
		$sJsonInvoiceOthersOwn &= '"TaxExclusiveAmount" : 0,' & @CRLF
		$sJsonInvoiceOthersOwn &= '"TaxAmount" : 0,' & @CRLF
		$sJsonInvoiceOthersOwn &= '"PayableAmount" : ' & Round($iIngresosTercerosTotal, 2) & @CRLF
		$sJsonInvoiceOthersOwn &= '},' & @CRLF
		Return $sJsonInvoiceOthersOwn
	ElseIf $sInfoType = "InvoiceTotal" Then
		If $aJsonDataArray[99][1] <= 0 Then
			Local $iPrePaidAmount = 0
		Else
			Local $iPrePaidAmount = $aJsonDataArray[99][1] / 100
		EndIf
		Local $sJsonInvoiceTotal
		$sJsonInvoiceTotal &= '"InvoiceTotal": {' & @CRLF
		$sJsonInvoiceTotal &= '"LineExtensionAmount": ' & Round($iIngresosGravadosTotal + $iIngresosExcluidosTotal + $iIngresosTercerosTotal, 2) & ',' & @CRLF
		$sJsonInvoiceTotal &= '"TaxExclusiveAmount": ' & Round($iIngresosGravadosTotal, 2) & ',' & @CRLF
		$sJsonInvoiceTotal &= '"TaxInclusiveAmount": ' & Round($iIngresosGravadosTotal + $iIngresosExcluidosTotal + $iIngresosTercerosTotal + $iIVATotal, 2) & ',' & @CRLF
		$sJsonInvoiceTotal &= '"AllowanceTotalAmount": 0,' & @CRLF
		$sJsonInvoiceTotal &= '"ChargeTotalAmount": 0,' & @CRLF
		$sJsonInvoiceTotal &= '"PrePaidAmount": ' & Round($iPrePaidAmount, 2) & ',' & @CRLF
		$sJsonInvoiceTotal &= '"PayableAmount": ' & Round(($iIngresosGravadosTotal + $iIngresosExcluidosTotal + $iIngresosTercerosTotal + $iIVATotal) - $iPrePaidAmount, 2) & @CRLF
		$sJsonInvoiceTotal &= '},' & @CRLF
		$sJsonInvoiceTotal &= '"Documents": []' & @CRLF
		Return $sJsonInvoiceTotal
	EndIf
	If $iIVATotal > 0 Then
		$aIVA = _Calc_IVA($aArrayData)
		Local $aIvaGnralData[1][$iColIndex]
		$aIvaGnralData[0][0] = 0
		$aIvaGnralData[0][1] = "01"
		$aIvaGnralData[0][2] = "false"
		$aIvaGnralData[0][3] = "IngresoPropio"
		$aIvaGnralData[0][4] = $iIngresosGravadosTotal
		$aIvaGnralData[0][5] = "100%"
		$aIvaGnralData[0][6] = Round(($iIVATotal / $iIngresosGravadosTotal) * 100, 1)
		$aIvaGnralData[0][7] = $iIVATotal
		$aIvaGnralData[0][8] = $iIVATotal
	EndIf
	If $iRtfTotal > 0 Then
		$aRetefuente = _Calc_Retefuente($aArrayData)
		If $iRtfExcluidos > 0 Then
			Local $aRtfExcGnralData[1][$iColIndex]
			$aRtfExcGnralData[0][0] = 0
			$aRtfExcGnralData[0][1] = "06"
			$aRtfExcGnralData[0][2] = "true"
			$aRtfExcGnralData[0][3] = "IngresoPropioExcluido"
			$aRtfExcGnralData[0][4] = $iIngresosExcluidosTotal
			$aRtfExcGnralData[0][5] = "100%"
			$aRtfExcGnralData[0][6] = Round(($iRtfExcluidos / $iIngresosExcluidosTotal) * 100, 1)
			$aRtfExcGnralData[0][7] = $iRtfExcluidos
			$aRtfExcGnralData[0][8] = $iRtfExcluidos
		EndIf
		If $iRtfPropiosTotal > 0 Then
			Local $aRtfPropGnralData[1][$iColIndex]
			$aRtfPropGnralData[0][0] = 0
			$aRtfPropGnralData[0][1] = "06"
			$aRtfPropGnralData[0][2] = "true"
			$aRtfPropGnralData[0][3] = "IngresoPropio"
			$aRtfPropGnralData[0][4] = $iIngresosGravadosTotal
			$aRtfPropGnralData[0][5] = "100%"
			$aRtfPropGnralData[0][6] = Round(($iRtfPropiosTotal / $iIngresosGravadosTotal) * 100, 1)
			$aRtfPropGnralData[0][7] = $iRtfPropiosTotal
			$aRtfPropGnralData[0][8] = $iRtfPropiosTotal
		EndIf
	EndIf
	If $iRtICATotal > 0 Then
		$aICA = _Calc_ICA($aArrayData)
	EndIf
	If $iRtIVATotal > 0 Then
		$aReteIVA = _Calc_ReteIVA($aArrayData)
	EndIf
	_ArrayConcatenate($aTaxesDetail, $aIVA)

	_ArrayConcatenate($aTaxesDetail, $aRetefuente)
	_ArraySort($aTaxesDetail)

	_ArrayConcatenate($aTaxesGeneral, $aICA)
	_ArrayConcatenate($aTaxesGeneral, $aReteIVA)
	_ArrayConcatenate($aTaxesGeneral, $aIvaGnralData)
	_ArrayConcatenate($aTaxesGeneral, $aRtfExcGnralData)
	_ArrayConcatenate($aTaxesGeneral, $aRtfPropGnralData)
	_ArraySort($aTaxesGeneral)
	Local $aResponse[2] = [$aTaxesDetail, $aTaxesGeneral]
	Return $aResponse
EndFunc   ;==>_TaxesDetailed

Func _Calc_ReteIVA($aArrayData)
	Local $iRtIVA = 15.0
	Local $iIVATotal = $aArrayData[7]
	Local $iRtIVATotal = $aArrayData[9]
	Local $iIngresosGravadosTotal = $aArrayData[1]
	Local $iRtIVA = $iRtIVATotal / $iIVATotal
	Local $iIVA_Percent = Round($iRtIVA, 2)
	$iIVA_Percent = $iIVA_Percent * 100
	$iIVA_Percent = Round($iIVA_Percent, 3)
	If ($iRtIVA / $iIVA_Percent) > 0.99 And ($iRtIVA / $iIVA_Percent) < 1.01 Then
		Local $iRtIVA_Percent = $iRtIVA
	Else
		Local $iRtIVA_Percent = $iIVA_Percent
	EndIf
	Local $aRteIvaData[1][$iColIndex]
	$aRteIvaData[0][0] = 0
	$aRteIvaData[0][1] = "05"
	$aRteIvaData[0][2] = "true"
	$aRteIvaData[0][3] = "ReteIVA"
	$aRteIvaData[0][4] = $iIngresosGravadosTotal
	$aRteIvaData[0][5] = "100%"
	$aRteIvaData[0][6] = $iRtIVA_Percent
	$aRteIvaData[0][7] = $iRtIVATotal
	$aRteIvaData[0][8] = $iRtIVATotal
	Return $aRteIvaData
EndFunc   ;==>_Calc_ReteIVA

Func _Calc_ICA($aArrayData)
	Local $iIngresosGravadosTotal = $aArrayData[1]
	Local $iIngresosExcluidosTotal = $aArrayData[2]
	Local $iRtICATotal = $aArrayData[8]
	If $iIngresosGravadosTotal <= 0 Then $iIngresosGravadosTotal = 1
	If $iIngresosExcluidosTotal <= 0 Then $iIngresosExcluidosTotal = 1
	Local $iPercentICA_GravadosTotal = $iRtICATotal / $iIngresosGravadosTotal
	Local $iPercentICA_ExcluidosTotal = $iRtICATotal / $iIngresosExcluidosTotal
	Local $iICA_Base = 0
	Local $iICA_Percent = 0
	Select
		Case $iPercentICA_GravadosTotal < 1 And $iPercentICA_ExcluidosTotal < 1
			Local $iICA_Percent_Prop = Calc_IcaPercent($iPercentICA_GravadosTotal, $iIngresosGravadosTotal)
			Local $iICA_Percent_Excl = Calc_IcaPercent($iPercentICA_ExcluidosTotal, $iIngresosExcluidosTotal)
			If $iICA_Percent_Prop > 0 Then
				Local $iICA_Base = $iIngresosGravadosTotal
				$iICA_Percent = $iICA_Percent_Prop
			ElseIf $iICA_Percent_Excl > 0 Then
				Local $iICA_Percent = $iPercentICA_ExcluidosTotal
				$iICA_Percent = $iICA_Percent_Excl
			Else
				$iICA_Percent = 0
			EndIf
		Case $iPercentICA_GravadosTotal < 1 And $iPercentICA_ExcluidosTotal >= 1
			Local $iICA_Percent = $iPercentICA_GravadosTotal
			Local $iICA_Base = $iIngresosGravadosTotal
			$iICA_Percent = Calc_IcaPercent($iICA_Percent, $iICA_Base)
		Case $iPercentICA_GravadosTotal >= 1 And $iPercentICA_ExcluidosTotal < 1
			Local $iICA_Percent = $iPercentICA_ExcluidosTotal
			Local $iICA_Base = $iIngresosExcluidosTotal
			$iICA_Percent = Calc_IcaPercent($iICA_Percent, $iICA_Base)
	EndSelect
	
	Local $aRteIcaData[1][$iColIndex]
	$aRteIcaData[0][0] = 0
	$aRteIcaData[0][1] = "07"
	$aRteIcaData[0][2] = "true"
	$aRteIcaData[0][3] = "ReteICA"
	$aRteIcaData[0][4] = $iICA_Base
	$aRteIcaData[0][5] = "100%"
	$aRteIcaData[0][6] = $iICA_Percent
	$aRteIcaData[0][7] = $iRtICATotal
	$aRteIcaData[0][8] = $iRtICATotal
	Return $aRteIcaData
EndFunc   ;==>_Calc_ICA

Func Calc_IcaPercent($iICA_Percent, $iICA_Base)
	Local $iICA_Fletes = 0.414
	Local $iICA_Servicios = 0.966
	$iICA_Percent = $iICA_Percent * 100
	$iICA_Percent = Round($iICA_Percent, 3)
	If ($iICA_Fletes / $iICA_Percent) > 0.99 And ($iICA_Fletes / $iICA_Percent) < 1.01 Then
		$iICA_Percent = $iICA_Fletes
		Return $iICA_Percent
	ElseIf ($iICA_Servicios / $iICA_Percent) > 0.99 And $iICA_Servicios / $iICA_Percent < 1.01 Then
		$iICA_Percent = $iICA_Servicios
		Return $iICA_Percent
	Else
		Return $iICA_Percent
	EndIf
EndFunc   ;==>Calc_IcaPercent

Func _Calc_IVA($aArrayData)
	Local $aTaxesData = $aArrayData[0]
	Local $iIngresosGravadosTotal = $aArrayData[1]
	Local $iIVATotal = $aArrayData[7]
	Local $aTaxesPropData[1][$iColIndex]
	Local $aTempRtePropData[1][$iColIndex]
	For $i = 3 To UBound($aTaxesData) - 1 Step +1
		Local $sIncomingType = $aTaxesData[$i][6]
		If $sIncomingType = "IngresoPropio" Then
			Local $iDiscIncoming = $aTaxesData[$i][0]
			Local $iPercentDiscIncoming = $iDiscIncoming / $iIngresosGravadosTotal
			$iPercentDiscIncoming = Round($iPercentDiscIncoming, 2)
			Local $iAproxIVA_Percent = $iIVATotal / $iIngresosGravadosTotal
			Local $iIVA_Value = $iDiscIncoming * $iAproxIVA_Percent
			$iIVA_Value = Round($iIVA_Value, 2)
			$iAproxIVA_Percent = Round($iAproxIVA_Percent, 3)
			$aTempRtePropData[0][0] = $aTaxesData[$i][7]
			$aTempRtePropData[0][1] = "01"
			$aTempRtePropData[0][2] = "false"
			$aTempRtePropData[0][3] = $sIncomingType
			$aTempRtePropData[0][4] = $iDiscIncoming
			$aTempRtePropData[0][5] = Number($iPercentDiscIncoming * 100) & "%"
			$aTempRtePropData[0][6] = Number($iAproxIVA_Percent * 100)
			$aTempRtePropData[0][7] = $aTaxesData[$i][1]
			$aTempRtePropData[0][8] = $iIVATotal
			_ArrayAdd($aTaxesPropData, $aTempRtePropData)
		EndIf
	Next
	If UBound($aTaxesPropData) > 0 Then
		Local $aExtracted = _ArrayExtract($aTaxesPropData, 1, UBound($aTaxesPropData) - 1)
		Return $aExtracted
	Else
		Return 0
	EndIf
EndFunc   ;==>_Calc_IVA

Func _Calc_Retefuente($aArrayData)
	Local $aTaxesData = $aArrayData[0]
	Local $iIngresosGravadosTotal = $aArrayData[1]
	Local $iIngresosExcluidosTotal = $aArrayData[2]
	Local $iRtfPropiosTotal = $aArrayData[4]
	Local $iRtfExcluidos = $aArrayData[6]
	Local $aPropTaxes = _Calc_RtfProp($aTaxesData, $iIngresosGravadosTotal, $iRtfPropiosTotal)
	Local $aRtfPropExcl = _Calc_RtfPropExcl($aTaxesData, $iIngresosExcluidosTotal, $iRtfExcluidos)
	Select
		Case IsArray($aPropTaxes) = 1 And IsArray($aRtfPropExcl) = 1
			_ArrayConcatenate($aPropTaxes, $aRtfPropExcl)
			Local $aRetefuentes = $aPropTaxes
		Case IsArray($aPropTaxes) = 0 And IsArray($aRtfPropExcl) = 1
			Local $aRetefuentes = $aRtfPropExcl
		Case IsArray($aPropTaxes) = 1 And IsArray($aRtfPropExcl) = 0
			Local $aRetefuentes = $aPropTaxes
	EndSelect
	_ArraySort($aPropTaxes)
	Return $aRetefuentes
EndFunc   ;==>_Calc_Retefuente

Func _Calc_RtfProp($aTaxesData, $iIngresosGravadosTotal, $iRtfPropiosTotal)
	Local $aTaxesPropData[1][$iColIndex]
	For $i = 3 To UBound($aTaxesData) - 1 Step +1
		Local $aTempRtePropData[1][$iColIndex]
		Local $sIncomingType = $aTaxesData[$i][6]
		If $sIncomingType = "IngresoPropio" Then
			Local $iDiscIncoming = $aTaxesData[$i][0]
			Local $iPercentDiscIncoming = $iDiscIncoming / $iIngresosGravadosTotal
			$iPercentDiscIncoming = Round($iPercentDiscIncoming, 2)
			Local $iAproxRtfPercent = $iRtfPropiosTotal / $iIngresosGravadosTotal
			Local $iRtfValue = $iDiscIncoming * $iAproxRtfPercent
			$iRtfValue = Round($iRtfValue, 2)
			$iAproxRtfPercent = Round($iAproxRtfPercent, 3)
			$aTempRtePropData[0][0] = $aTaxesData[$i][7]
			$aTempRtePropData[0][1] = "06"
			$aTempRtePropData[0][2] = "true"
			$aTempRtePropData[0][3] = $sIncomingType
			$aTempRtePropData[0][4] = $iDiscIncoming
			$aTempRtePropData[0][5] = Number($iPercentDiscIncoming * 100) & "%"
			$aTempRtePropData[0][6] = Number($iAproxRtfPercent * 100)
			$aTempRtePropData[0][7] = $iRtfValue
			$aTempRtePropData[0][8] = $iRtfPropiosTotal
			_ArrayAdd($aTaxesPropData, $aTempRtePropData)
		EndIf
	Next
	If UBound($aTaxesPropData) > 0 Then
		Local $aExtracted = _ArrayExtract($aTaxesPropData, 1, UBound($aTaxesPropData) - 1)
		Return $aExtracted
	Else
		Return 0
	EndIf

EndFunc   ;==>_Calc_RtfProp

Func _Calc_RtfPropExcl($aTaxesData, $iIngresosExcluidosTotal, $iRtfExcluidos)
	Local $aRtePropExclData[1][$iColIndex]
	Local $aTempRtePropExclData[1][$iColIndex]
	For $i = 3 To UBound($aTaxesData) - 1 Step +1
		Local $sIncomingType = $aTaxesData[$i][6]
		If $sIncomingType = "IngresoPropioExcluido" Then
			Local $iDiscIncoming = $aTaxesData[$i][0]
			Local $iPercentDiscIncoming = $iDiscIncoming / $iIngresosExcluidosTotal
			$iPercentDiscIncoming = Round($iPercentDiscIncoming, 2)
			Local $iAproxRtfPercent = $iRtfExcluidos / $iIngresosExcluidosTotal
			Local $iRtfValue = $iDiscIncoming * $iAproxRtfPercent
			$iRtfValue = Round($iRtfValue, 2)
			$iAproxRtfPercent = Round($iAproxRtfPercent, 3)
			$aTempRtePropExclData[0][0] = $aTaxesData[$i][7]
			$aTempRtePropExclData[0][1] = "06"
			$aTempRtePropExclData[0][2] = "true"
			$aTempRtePropExclData[0][3] = $sIncomingType
			$aTempRtePropExclData[0][4] = $iDiscIncoming
			$aTempRtePropExclData[0][5] = Number($iPercentDiscIncoming * 100) & "%"
			$aTempRtePropExclData[0][6] = Number($iAproxRtfPercent * 100)
			$aTempRtePropExclData[0][7] = $iRtfValue
			$aTempRtePropExclData[0][8] = $iRtfExcluidos
			_ArrayAdd($aRtePropExclData, $aTempRtePropExclData)
		EndIf
	Next
	If UBound($aRtePropExclData) > 0 Then
		Local $aExtracted = _ArrayExtract($aRtePropExclData, 1, UBound($aRtePropExclData) - 1)
		Return $aExtracted
	Else
		Return 0
	EndIf
EndFunc   ;==>_Calc_RtfPropExcl

Func _Calc_IngresosGravados_Total($aTaxesData)
	Local $iIngresoExcluido = 0
	For $i = 3 To UBound($aTaxesData) - 1 Step +1
		Local $sIncomingType = $aTaxesData[$i][6]
		If $sIncomingType = "IngresoPropio" Then
			$iIngresoExcluido += $aTaxesData[$i][0]
		EndIf
	Next
	Return Number($iIngresoExcluido)
EndFunc   ;==>_Calc_IngresosGravados_Total

Func _Calc_IngresosExcluidos_Total($aTaxesData)
	Local $iIngresoExcluido = 0
	For $i = 3 To UBound($aTaxesData) - 1 Step +1
		Local $sIncomingType = $aTaxesData[$i][6]
		If $sIncomingType == "IngresoPropioExcluido" Then
			$iIngresoExcluido += $aTaxesData[$i][0]
		EndIf
	Next
	Return Number($iIngresoExcluido)
EndFunc   ;==>_Calc_IngresosExcluidos_Total

Func _Calc_IngresosTerceros_Total($aTaxesData)
	Local $iIngresoExcluido = 0
	For $i = 3 To UBound($aTaxesData) - 1 Step +1
		Local $sIncomingType = $aTaxesData[$i][6]
		If $sIncomingType = "IngresoTercero" Then
			$iIngresoExcluido += $aTaxesData[$i][0]
		EndIf
	Next
	Return Number($iIngresoExcluido)
EndFunc   ;==>_Calc_IngresosTerceros_Total

Func _Calc_RtfPropios_Total($aTaxesData)
	Local $iRTF_Total = 0
	For $i = 3 To UBound($aTaxesData) - 1 Step +1
		Local $sIncomingType = $aTaxesData[$i][6]
		If $sIncomingType == "IngresoPropio" Then
			Local $iRTF_Total = $aTaxesData[$i][3]
			If $iRTF_Total > 0 Then Return $iRTF_Total
		EndIf
	Next
	Return Number($iRTF_Total)
EndFunc   ;==>_Calc_RtfPropios_Total

Func _Calc_Rtf_Total($aTaxesData)
	For $i = 3 To UBound($aTaxesData) - 1 Step +1
		Local $iRTF_Total = $aTaxesData[$i][3]
		If $iRTF_Total > 0 Then Return Number($iRTF_Total)
	Next
	Return 0
EndFunc   ;==>_Calc_Rtf_Total

Func _Calc_IVA_Total($aTaxesData)
	Local $iIVA_Disc = 0
	For $i = 3 To UBound($aTaxesData) - 1 Step +1
		$iIVA_Disc += $aTaxesData[$i][1]
	Next
	Return Number($iIVA_Disc)
EndFunc   ;==>_Calc_IVA_Total

Func _Calc_RtICA_Total($aTaxesData)
	For $i = 3 To UBound($aTaxesData) - 1 Step +1
		Local $iRtICA_Total = $aTaxesData[$i][4]
		Local $sIncomingType = $aTaxesData[$i][6]
		If $iRtICA_Total > 0 Then Return Number($iRtICA_Total)
	Next
	Return 0
EndFunc   ;==>_Calc_RtICA_Total

Func _Calc_RtIVA_Total($aTaxesData)
	For $i = 3 To UBound($aTaxesData) - 1 Step +1
		Local $iRtIVA_Total = $aTaxesData[$i][5]
		Local $sIncomingType = $aTaxesData[$i][6]
		If $iRtIVA_Total > 0 And $sIncomingType = "IngresoPropio" Then Return Number($iRtIVA_Total)
	Next
	Return 0
EndFunc   ;==>_Calc_RtIVA_Total

Func _TaxesData($aJsonDataArray)
	Local $aTaxesItems = _aTaxesItems($aJsonDataArray)
	For $i = 1 To UBound($aJsonDataArray, 2) - 1 Step +1
		If StringStripWS(StringUpper($aJsonDataArray[69][$i]), 8) == 'COP' Then
			Local $iTasaCambio = 1
		Else
			Local $iTasaCambio = $aJsonDataArray[76][$i]
		EndIf
		Local $iAmount = Number($aJsonDataArray[27][$i]) / Number($iTasaCambio)
		Local $iIVA_Disc = Number($aJsonDataArray[34][$i]) / Number($iTasaCambio)
		Local $iRTF_Disc = Number($aJsonDataArray[39][$i]) / Number($iTasaCambio)
		Local $iIVA_Total = Number($aJsonDataArray[51][$i]) / Number($iTasaCambio)
		Local $iRetefuente = Number($aJsonDataArray[56][$i]) / Number($iTasaCambio)
		Local $iReteICA = Number($aJsonDataArray[61][$i]) / Number($iTasaCambio)
		Local $iReteIVA = Number($aJsonDataArray[66][$i]) / Number($iTasaCambio)
		If StringStripWS($aJsonDataArray[0][1], 8) == "900467836" Then $iIVA_Disc = $iIVA_Total
		$iIVA_Disc = _CheckNegative($iIVA_Disc)
		$iRTF_Disc = _CheckNegative($iRTF_Disc)
		$iIVA_Total = _CheckNegative($iIVA_Total)
		$iRetefuente = _CheckNegative($iRetefuente)
		$iReteICA = _CheckNegative($iReteICA)
		$iReteIVA = _CheckNegative($iReteIVA)
		$iRTF_Disc = Round($iRTF_Disc, 2)
		$iIVA_Total = Round($iIVA_Total, 2)
		$iRetefuente = Round($iRetefuente, 2)
		$iReteICA = Round($iReteICA, 2)
		$iReteIVA = Round($iReteIVA, 2)
		Local $sIncomingType = $aJsonDataArray[102][$i]
		If StringInStr($sIncomingType, 'TER') > 0 Then     ;Ingresos terceros
			Local $iIncomingType = "IngresoTercero"
			$iIVA_Disc = 0
			$iRTF_Disc = 0
			$iRetefuente = 0
			$iReteICA = 0
			$iReteIVA = 0
		ElseIf StringInStr($sIncomingType, 'PRO') Then
			If $iIVA_Disc > 0 Then
				Local $iIncomingType = "IngresoPropio"
			Else
				Local $iIncomingType = "IngresoPropioExcluido"
				$iReteIVA = 0
			EndIf
		EndIf
		$aTaxesItems[$i + 2][0] = Round($iAmount, 2)
		$aTaxesItems[$i + 2][1] = Round($iIVA_Disc, 2)
		$aTaxesItems[$i + 2][2] = Round($iRTF_Disc, 2)
		$aTaxesItems[$i + 2][3] = Round($iRetefuente, 2)
		$aTaxesItems[$i + 2][4] = Round($iReteICA, 2)
		$aTaxesItems[$i + 2][5] = Round($iReteIVA, 2)
		$aTaxesItems[$i + 2][6] = $iIncomingType
		$aTaxesItems[$i + 2][7] = $i
	Next
	Return $aTaxesItems
EndFunc   ;==>_TaxesData

Func _aTaxesItems($aJsonDataArray)
	Local $iLimitData = UBound($aJsonDataArray, 2) + 2 ;Define el tamaño del arreglo de filas de acuerdo a la cantidad de items
	Local $aTaxesItems[$iLimitData][8]
	$aTaxesItems[0][0] = "AMOUNT"
	$aTaxesItems[0][1] = "IVA_DISC"
	$aTaxesItems[0][2] = "RTF_DISC"
	$aTaxesItems[0][3] = "RTF_TOTAL"
	$aTaxesItems[0][4] = "RT_ICA"
	$aTaxesItems[0][5] = "RT_IVA"
	$aTaxesItems[0][6] = "INCOMING"
	$aTaxesItems[0][7] = StringRegExpReplace($aJsonDataArray[0][1], "[^[:digit:]]", "")
	$aTaxesItems[1][0] = "TAX_ID ->"
	$aTaxesItems[1][1] = "01"
	$aTaxesItems[1][2] = "06"
	$aTaxesItems[1][3] = "06"
	$aTaxesItems[1][4] = "05"
	$aTaxesItems[1][5] = "07"
	$aTaxesItems[1][6] = "<- TAX_ID"
	$aTaxesItems[2][0] = "TAX_EV_IND ->"
	$aTaxesItems[2][1] = "false"
	$aTaxesItems[2][2] = "true"
	$aTaxesItems[2][3] = "true"
	$aTaxesItems[2][4] = "true"
	$aTaxesItems[2][5] = "true"
	$aTaxesItems[2][6] = "<- TAX_EV_IND"
	
	Return $aTaxesItems
EndFunc   ;==>_aTaxesItems
