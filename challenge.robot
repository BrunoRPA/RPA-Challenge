*** Settings ***
Library  SeleniumLibrary      
Library  RPA.Excel.Files      
Library  Collections          
Library  String               
Library  OperatingSystem      

*** Variables ***
${URL}       https://rpachallenge.com/   
${EXCEL}     challenge.xlsx            
${BROWSER}   Chrome                     

*** Test Cases ***
Complete RPA Challenge
    Open Browser  ${URL}  ${BROWSER}    
    Maximize Browser Window
    Click Button  xpath=//button[contains(text(),'Start')]
    
    # Leer el archivo Excel y obtiene los datos
    ${data}  Read Excel File  ${EXCEL}
    
    # Recorrer las filas del archivo Excel y completa el formulario
    FOR  ${row}  IN  @{data}    
        Fill And Submit Form  ${row}  # Completa y envía el formulario con los datos de cada fila
    END

    Log To Console  "*** Formulario completado. El navegador permanecerá abierto. ***"
    
    Sleep  10s
    Close Browser  

*** Keywords ***
Read Excel File
    [Arguments]    ${file_path}
    RPA.Excel.Files.Open Workbook    ${file_path}
    ${data}    RPA.Excel.Files.Read Worksheet As Table    header=True
    RPA.Excel.Files.Close Workbook
    RETURN    ${data}



Fill And Submit Form
    [Arguments]  ${row}
    # Obtiene todos los elementos de tipo etiqueta (label) en la página
    ${fields}  Get WebElements  //label
    
    # Recorrer los campos para llenarlos con los valores del Excel
    FOR  ${field}  IN  @{fields} 
        ${label}  Get Text  ${field}  # Obtiene el texto de la etiqueta

        ${label}  Strip String  ${label}  # Elimina espacios en blanco al principio y al final del texto

        # Encuentra el campo de entrada correspondiente a la etiqueta
        ${input_locator}  Set Variable  xpath=//label[contains(text(),'${label}')]/following-sibling::input
        
        # Obtiene el valor correspondiente al campo desde el Excel
        ${value}  Get From Dictionary  ${row}  ${label}

        # Si el valor no está vacío, lo ingresa en el campo
        Run Keyword If  '${value}' != ''  Input Text  ${input_locator}  ${value}
    END

    Click Button  xpath=//input[@type='submit']
