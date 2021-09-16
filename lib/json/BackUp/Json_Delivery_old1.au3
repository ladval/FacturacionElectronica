Func _JSON_Delivery($aArray)
_ArrayDisplay($aArray,'$aArray')

	Local $aDelivery_AddressLine[5]
	$aDelivery_AddressLine[0] = "AddressLine"
	$aDelivery_AddressLine[1] = "NoData"
	$aDelivery_AddressLine[2] = '"' & $aArray[13][1] & '"'
	$aDelivery_AddressLine[3] = "OPCIONAL"
	$aDelivery_AddressLine[4] = "Dirección de despacho de la mercancía referenciada en la factura"
	Local $aDelivery_CountryCode[5]
	$aDelivery_CountryCode[0] = "CountryCode"
	$aDelivery_CountryCode[1] = "NoData"
	$aDelivery_CountryCode[2] = "null"
	$aDelivery_CountryCode[3] = "REQUERIDO"
	$aDelivery_CountryCode[4] = "Código del país del despacho según los códigos ISO 3166 -1 alfa 2 Tabla de referencia Anexo API V2 1.1.9. Países (ISO 3166 -1)."
	Local $aDelivery_CountryName[5]
	$aDelivery_CountryName[0] = "CountryName"
	$aDelivery_CountryName[1] = "NoData"
	$aDelivery_CountryName[2] = "null"
	$aDelivery_CountryName[3] = "REQUERIDO"
	$aDelivery_CountryName[4] = "Nombre del país del despacho según lo codificado en tabla de referencia Anexo API V2 1.1.9. Países (ISO 3166 - 1)."
	Local $aDelivery_SubdivisionCode[5]
	$aDelivery_SubdivisionCode[0] = "SubdivisionCode"
	$aDelivery_SubdivisionCode[1] = "NoData"
	$aDelivery_SubdivisionCode[2] = "null"
	$aDelivery_SubdivisionCode[3] = "OPCIONAL"
	$aDelivery_SubdivisionCode[4] = "Solamente cuando el país es Colombia en este campo se indicará el código DIVIPOLA del departamento del despacho. De lo contrario será null "
	Local $aDelivery_SubdivisionName[5]
	$aDelivery_SubdivisionName[0] = "SubdivisionName"
	$aDelivery_SubdivisionName[1] = "NoData"
	$aDelivery_SubdivisionName[2] = "null"
	$aDelivery_SubdivisionName[3] = "REQUERIDO"
	$aDelivery_SubdivisionName[4] = "Cuando el país del adquirente es Colombia en este campo se indicará nombre del departamento del despacho según el estándar DIVIPOLA. Cuando el país del adquirente no es Colombia, se indicará la región del país en el que se ubica el adquirente en texto libre."
	Local $aDelivery_CityCode[5]
	$aDelivery_CityCode[0] = "CityCode"
	$aDelivery_CityCode[1] = "NoData"
	$aDelivery_CityCode[2] = "null"
	$aDelivery_CityCode[3] = "OPCIONAL"
	$aDelivery_CityCode[4] = "Solamente cuando el país es Colombia en este campo se indicará el código DIVIPOLA de la ciudad a la que se despacha. De lo contrario será null"
	Local $aDelivery_CityName[5]
	$aDelivery_CityName[0] = "CityName"
	$aDelivery_CityName[1] = "NoData"
	$aDelivery_CityName[2] = "null"
	$aDelivery_CityName[3] = "REQUERIDO"
	$aDelivery_CityName[4] = "Cuando el país del adquirente es Colombia en este campo se indicará  nombre de la ciudad del despacho según el estándar DIVIPOLA. Cuando el país del adquirente no es Colombia, se indicará la el nombre de la ciudad del país en el que se hace el despacho en texto libre"
	Local $aDelivery_ContactPerson[5]
	$aDelivery_ContactPerson[0] = "ContactPerson"
	$aDelivery_ContactPerson[1] = "NoData"
	$aDelivery_ContactPerson[2] = "null"
	$aDelivery_ContactPerson[3] = "OPCIONAL"
	$aDelivery_ContactPerson[4] = "Nombre de la persona de contacto en la dirección de despacho."
	Local $aDelivery_DeliveryDate[5]
	$aDelivery_DeliveryDate[0] = "DeliveryDate"
	$aDelivery_DeliveryDate[1] = "NoData"
	$aDelivery_DeliveryDate[2] = '"' & @YEAR & "-" & @MON & "-" & @MDAY & "T" & @HOUR & ":" & @MIN & ":" & @SEC & '"'
	$aDelivery_DeliveryDate[3] = "OPCIONAL"
	$aDelivery_DeliveryDate[4] = "Fecha en la que se ejecuta el despacho / entrega ('0001-01- 01T00:00:00')"
	Local $aDelivery_DeliveryCompany[5]
	$aDelivery_DeliveryCompany[0] = "DeliveryCompany"
	$aDelivery_DeliveryCompany[1] = "NoData"
	$aDelivery_DeliveryCompany[2] = "null"
	$aDelivery_DeliveryCompany[3] = "OPCIONAL"
	$aDelivery_DeliveryCompany[4] = "Nombre de la empresa transportadora"
	Local $aResultArray[11]
	$aResultArray[0] = "Delivery"
	$aResultArray[1] = $aDelivery_AddressLine
	$aResultArray[2] = $aDelivery_CountryCode
	$aResultArray[3] = $aDelivery_CountryName
	$aResultArray[4] = $aDelivery_SubdivisionCode
	$aResultArray[5] = $aDelivery_SubdivisionName
	$aResultArray[6] = $aDelivery_CityCode
	$aResultArray[7] = $aDelivery_CityName
	$aResultArray[8] = $aDelivery_ContactPerson
	$aResultArray[9] = $aDelivery_DeliveryDate
	$aResultArray[10] = $aDelivery_DeliveryCompany
	$aJSON_CustomerInfo_2DArray = _JSON_1Darray($aResultArray)
	$aResultArray = _JSON_JsonData($aJSON_CustomerInfo_2DArray)
	Return $aResultArray
EndFunc   ;==>_JSON_Delivery
