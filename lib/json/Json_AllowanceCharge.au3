#include <Array.au3>
; #FUNCTION# ===================================================================
; Name ..........: _InvoiceAllowanceCharge
; Description ...: Function that generates total allowance JSON, the individual allowances values and the total value.
; Parameters ....: $aArray      		 - [REQUIRED] All the data extracted from the array invoice
;				   $aTaxesGnralData      - [REQUIRED] The taxes data generated by _TaxesGnralData
;				   $sDataType      		 - [OPTIONAL] JSON Default. The string parameter that defines result.
; Return values .: On Success 			 - Total allowance JSON, the individual allowances values and the total value
; Author ........: Jesús A. Ladino
; ==============================================================================
Func _InvoiceAllowanceCharge($aArray, $aTaxesGnralData, $sDataType = "JSON")
	Local $aJSON_AllowancesResponse[0]
	Local $iSum_AllowanceAmount_Retefuente = 0
	Local $iSum_AllowanceAmount_ReteICA = 0
	Local $iSum_AllowanceAmount_ReteIVA = 0
	Local $iAllowanceAmount_Retefuente = 0
	Local $iAllowanceAmount_ReteICA = 0
	Local $iAllowanceAmount_ReteIVA = 0
	Local $iCount = 0
	For $i = 0 To UBound($aTaxesGnralData) - 1 Step +1
		If $aTaxesGnralData[$i][2] == 1 Then
			$iSum_AllowanceAmount_Retefuente += $aTaxesGnralData[$i][6]
			$iSum_AllowanceAmount_ReteICA += $aTaxesGnralData[$i][7]
			$iSum_AllowanceAmount_ReteIVA += $aTaxesGnralData[$i][8]
			$iCount += $aTaxesGnralData[$i][2]
		EndIf
	Next
	$iAllowanceAmount_Retefuente = $iSum_AllowanceAmount_Retefuente / $iCount
	$iAllowanceAmount_ReteICA = $iSum_AllowanceAmount_ReteICA / $iCount
	$iAllowanceAmount_ReteIVA = $iSum_AllowanceAmount_ReteIVA / $iCount
	Local $aAllowances[3] = [$iAllowanceAmount_Retefuente, $iAllowanceAmount_ReteICA, $iAllowanceAmount_ReteIVA]
	For $i = 0 To UBound($aAllowances) - 1 Step +1
		If $aAllowances[$i] > 0 Then
			$aJSON_Allowances = _InfoJSON_TotalAllowance($i, $aTaxesGnralData)
			_ArrayConcatenate($aJSON_AllowancesResponse, $aJSON_Allowances)
		EndIf
	Next
	If $aAllowances[0] + $aAllowances[1] + $aAllowances[2] > 0 Then $aJSON_AllowancesResponse[UBound($aJSON_AllowancesResponse) - 1] = "}"
	_ArrayAdd($aJSON_AllowancesResponse, '],')
	_ArrayAdd($aJSON_AllowancesResponse, '"InvoiceAllowanceCharge": [],')

	Return $aJSON_AllowancesResponse
EndFunc   ;==>_InvoiceAllowanceCharge

; #FUNCTION# ===================================================================
; Name ..........: _InfoJSON_TotalAllowance
; Description ...: Function that returns the JSON fragment with the allowance totals
; Parameters ....: $iIndex      		 - [REQUIRED] The index generated by _InvoiceAllowanceCharge inside the array of taxes
;				   $iAmount      		 - [REQUIRED] The allowance amount
;				   $aArray      		 - [REQUIRED] The aTaxesGnralData array
; Return values .: On Success 			 - JSON fragment with the allowance totals
; Author ........: Jesús A. Ladino
; ==============================================================================
Func _InfoJSON_TotalAllowance($iIndex, $aArray)
	Local $iSum_Gravado, $iSum_Iva, $iSum_Retefuente, $iSum_Reteica, $iSum_Reteiva, $iCount
	For $i = 0 To UBound($aArray) - 1 Step +1
		If $aArray[$i][2] == 1 Then
			$iSum_Gravado += $aArray[$i][3]
			$iSum_Iva += $aArray[$i][4]
			$iSum_Retefuente += $aArray[$i][6]
			$iSum_Reteica += $aArray[$i][7]
			$iSum_Reteiva += $aArray[$i][8]
			$iCount += $aArray[$i][2]
		EndIf
	Next
	Select
		Case $iIndex == 2                                                      ;Corresponde a la columna del arreglo que ingresa a la función.
			Local $sID_RtTax = "05"
			Local $iAmount = Round($iSum_Reteiva / $iCount, 2)
			Local $iBaseAmount = Round($iSum_Iva, 2)
			Local $iRtIVA_Crudo = $iAmount / $iBaseAmount
			Local $iRtIVA_Percent = $iRtIVA_Crudo * 100
			Local $iRtIVAEntero = Round($iRtIVA_Percent, 0)
			Local $sPercent = $iRtIVAEntero
			Local $sConcept_Default = "Retenc. IVA " & $iRtIVAEntero & "%"
		Case $iIndex == 0                                                       ;Corresponde a la columna del arreglo que ingresa a la función.
			Local $sID_RtTax = "06"
			Local $iAmount = Round($iSum_Retefuente / $iCount, 2)
			Local $iBaseAmount = Round($iSum_Gravado, 2)
			Local $iRtf_Crudo = $iAmount / $iBaseAmount
			Local $iRtf_Percent = $iRtf_Crudo * 100
			Local $iRtfEntero = Round($iRtf_Percent, 1)
			Local $sPercent = $iRtfEntero
			Local $sConcept_Default = "R.F. " & $sPercent & "%"
		Case $iIndex == 1                                                           ;Corresponde a la columna del arreglo que ingresa a la función.
			Local $sID_RtTax = "07"
			Local $iAmount = Round($iSum_Reteica / $iCount, 2)
			Local $iBaseAmount = Round($iSum_Gravado, 2)
			Local $iIca_Crudo = $iAmount / $iBaseAmount
			Local $iIca_Percent = $iIca_Crudo * 100
			Local $iIcaEntero = Round($iIca_Percent, 3)
			Local $sPercent = $iIcaEntero
			Local $sConcept_Default = "Retenc. ICA " & $sPercent & "%"
	EndSelect
	Local $aJsonAllowance[9]
	$aJsonAllowance[0] = '{'
	$aJsonAllowance[1] = '"Id" : "' & $sID_RtTax & '",'
	$aJsonAllowance[2] = '"TaxEvidenceIndicator" : true,'
	$aJsonAllowance[3] = '"TaxableAmount" : ' & $iBaseAmount & ','
	$aJsonAllowance[4] = '"TaxAmount" : ' & $iAmount & ','
	$aJsonAllowance[5] = '"Percent" : ' & $sPercent & ','
	$aJsonAllowance[6] = '"BaseUnitMeasure": "",'
	$aJsonAllowance[7] = '"PerUnitAmount": ""'
	$aJsonAllowance[8] = '},'
	Return $aJsonAllowance
EndFunc   ;==>_InfoJSON_TotalAllowance



