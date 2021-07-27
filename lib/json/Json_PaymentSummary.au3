Func _JSON_PaymentSummary($aArray)
	Local $aPaymentSummary_PaymentType[5]
	$aPaymentSummary_PaymentType[0] = "PaymentType"
	$aPaymentSummary_PaymentType[1] = "1" ;1 Contado, 2 Crédito
	$aPaymentSummary_PaymentType[2] = "0"
	$aPaymentSummary_PaymentType[3] = "REQUERIDO"
	$aPaymentSummary_PaymentType[4] = "Forma de pago. Tabla de referencia Anexo API V2 1.1.6. Formas de Pago: cbc:PaymentMeans/ID"
	Local $aPaymentSummary_PaymentMeans[5]
	$aPaymentSummary_PaymentMeans[0] = "PaymentMeans"
	$aPaymentSummary_PaymentMeans[1] = $aArray[67][1]
	$aPaymentSummary_PaymentMeans[2] = "null"
	$aPaymentSummary_PaymentMeans[3] = "REQUERIDO"
	$aPaymentSummary_PaymentMeans[4] = "Medio de pago Anexo API V2 1.1.7 Medios de Pago:cbc:PaymentMeansCode"
	Local $aPaymentSummary_PaymentNote[5]
	$aPaymentSummary_PaymentNote[0] = "PaymentNote"
	$aPaymentSummary_PaymentNote[1] = $aArray[68][1]
	$aPaymentSummary_PaymentNote[2] = "null"
	$aPaymentSummary_PaymentNote[3] = "OPCIONAL"
	$aPaymentSummary_PaymentNote[4] = "Instrucciones de pago"
	Local $aResultArray[4]
	$aResultArray[0] = "PaymentSummary"
	$aResultArray[1] = $aPaymentSummary_PaymentType
	$aResultArray[2] = $aPaymentSummary_PaymentMeans
	$aResultArray[3] = $aPaymentSummary_PaymentNote
	$aJSON_CustomerInfo_2DArray = _JSON_1Darray($aResultArray)
	$aResultArray = _JSON_JsonData($aJSON_CustomerInfo_2DArray)
;~ _ArrayDisplay($aResultArray)
	Return $aResultArray
EndFunc   ;==>_JSON_PaymentSummary


;~ "PaymentSummary": {
;~ 	"PaymentType": 0,
;~ 	"PaymentMeans": null,
;~ 	"PaymentNote": null
;~ },
